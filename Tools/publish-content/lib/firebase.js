// Writes what the app's publisher screens wrote: the cover image under PostImages, the Articles or Recipes
// document, its FeedItems entry and a "creation" ResourceActivities entry.
//
// Signs in with Application Default Credentials (`gcloud auth application-default login`), so there's no key
// file to keep. The Admin SDK skips the security rules, so the checks the rules made are made here instead.

import { randomUUID } from 'node:crypto';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore, Timestamp } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import sharp from 'sharp';

const COLLECTIONS = { article: 'Articles', recipe: 'Recipes' };

export function connect({ projectId, storageBucket }) {
    // With only one emulator set, the other half of each publish would go to the live project.
    if (Boolean(process.env.FIRESTORE_EMULATOR_HOST) !== Boolean(process.env.FIREBASE_STORAGE_EMULATOR_HOST)) {
        throw new Error('Set both FIRESTORE_EMULATOR_HOST and FIREBASE_STORAGE_EMULATOR_HOST, or neither.');
    }
    const app = initializeApp({ credential: applicationDefault(), projectId, storageBucket });
    return { db: getFirestore(app), bucket: getStorage(app).bucket(), storageBucket };
}

/** Article categories by lowercased name. */
export async function fetchArticleCategories({ db }) {
    const snapshot = await db.collection('ResourceCategories').where('resourceType', '==', 'article').get();
    return new Map(snapshot.docs.map((doc) => [doc.data().name.toLowerCase(), { id: doc.id, name: doc.data().name }]));
}

/** An article or recipe already published under this title, so running twice doesn't post it twice. */
export async function findPublished({ db }, type, title) {
    const snapshot = await db.collection(COLLECTIONS[type]).where('title', '==', title).limit(1).get();
    if (snapshot.empty) return null;
    const doc = snapshot.docs[0];
    return { id: doc.id, publicationDate: doc.data().publicationDate?.toDate() };
}

/** Like the app: the shorter side scaled down to 1024 px, JPEG at 50%, 5 MB at most. */
export async function prepareCover(imageFile) {
    const jpeg = await sharp(imageFile)
        .rotate()
        .resize({ width: 1024, height: 1024, fit: 'outside', withoutEnlargement: true })
        .flatten({ background: '#ffffff' })
        .jpeg({ quality: 50 })
        .toBuffer();
    if (jpeg.length > 5 * 1024 * 1024) throw new Error('The cover is over 5 MB even after compressing it.');
    return jpeg;
}

function downloadUrl(storageBucket, objectPath, token) {
    const emulator = process.env.FIREBASE_STORAGE_EMULATOR_HOST;
    const origin = emulator ? `http://${emulator.replace(/^https?:\/\//, '')}` : 'https://firebasestorage.googleapis.com';
    return `${origin}/v0/b/${storageBucket}/o/${encodeURIComponent(objectPath)}?alt=media&token=${token}`;
}

/** The Firestore fields for the item, matching `FirebaseArticleDoc` and `FirestoreRecipeDoc` in the app. */
export function contentDocument(item, { authorId, coverImageUrl, categoryIds = [] }) {
    const shared = {
        isPremium: item.isPremium,
        author: authorId,
        title: item.title,
        coverImageUrl,
        summary: item.summary,
        markdownContent: item.body,
        publicationDate: Timestamp.fromDate(item.publicationDate),
    };
    if (item.type === 'article') {
        return { ...shared, categories: categoryIds, citations: item.citations };
    }
    return {
        ...shared,
        prepTimeMinutes: item.prepTimeMinutes,
        cookTimeMinutes: item.cookTimeMinutes,
        servings: item.servings,
        difficultyLevel: item.difficultyLevel,
        ...(item.nutrition ?? {}),
    };
}

/**
 * Uploads the cover and writes the documents in one batch. If the batch fails, the cover is deleted again.
 * @returns {Promise<{ id: string, coverImageUrl: string }>}
 */
export async function publish(connection, item, { authorId, categoryIds }) {
    const { db, bucket, storageBucket } = connection;
    // Upper case, like Swift's `UUID().uuidString`.
    const id = randomUUID().toUpperCase();
    const imageId = randomUUID().toUpperCase();
    const objectPath = `PostImages/${authorId}/${id}/${imageId}.jpg`;
    const token = randomUUID();

    const file = bucket.file(objectPath);
    await file.save(await prepareCover(item.imageFile), {
        resumable: false,
        contentType: 'image/jpeg',
        metadata: { metadata: { firebaseStorageDownloadTokens: token } },
    });
    const coverImageUrl = downloadUrl(storageBucket, objectPath, token);

    const document = contentDocument(item, { authorId, coverImageUrl, categoryIds });
    const batch = db.batch();
    batch.set(db.collection(COLLECTIONS[item.type]).doc(id), document);
    batch.set(db.collection('FeedItems').doc(), {
        creatorUserId: authorId,
        resourceType: item.type,
        imageUrls: [coverImageUrl],
        publicationDate: document.publicationDate,
        resourceId: id,
        summary: item.summary,
        title: item.title,
    });
    batch.set(db.collection('ResourceActivities').doc(), {
        activityType: 'creation',
        userId: authorId,
        resourceId: id,
        resourceType: item.type,
        date: Timestamp.now(),
    });
    try {
        await batch.commit();
    } catch (error) {
        await file.delete().catch(() => {});
        throw error;
    }
    return { id, coverImageUrl };
}
