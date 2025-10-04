//
//  LocalUserDataFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/30/24.
//

import Foundation

protocol LocalUserDataFetcher {
    func fetchUser(userId: String) -> UserData?
    func save(userData: UserData)
}

class MockLocalUserDataFetcher: LocalUserDataFetcher {
    func fetchUser(userId: String) -> UserData? {
        .sample
    }
    
    func save(userData: UserData) {
        
    }
}

class UserDataCache: LocalUserDataFetcher {
    
    struct UserDataCacheEntry: Codable {
        
        let id: String?
        let fullName: String?
        let username: String?
        let profileImageUrl: URL?
        let bio: String?
        let whyCarnivore: String?
        let carnivoreSince: Date?
        
        static func from(_ userData: UserData) -> UserDataCacheEntry {
            UserDataCacheEntry(
                id: userData.id,
                fullName: userData.fullName?.value,
                username: userData.username?.value,
                profileImageUrl: userData.profileImageUrl,
                bio: userData.bio?.value,
                whyCarnivore: userData.whyCarnivore?.value,
                carnivoreSince: userData.carnivoreSince?.date
            )
        }
        
        func toUserData() -> UserData? {
            guard let id = id else { return nil }
            guard let username = Username(username ?? "") else { return nil }

            return .init(
                id: id,
                fullName: try? PersonName(fullName ?? ""),
                username: username,
                profileImageUrl: profileImageUrl,
                bio: UserBio(bio),
                whyCarnivore: WhyCarnivore(whyCarnivore),
                carnivoreSince: CarnivoreSince(carnivoreSince)
            )
        }
    }
    
    private typealias _UserDataCache = Cache<String, UserDataCacheEntry>
    
    private static let cacheName: String = "UserDataCache"
    
    private let cache: _UserDataCache = Cache.readFromDiskOrDefault(Cache.self, withName: UserDataCache.cacheName)
    
    public static let instance: UserDataCache = .init()
    public static func getInstance() -> UserDataCache { instance }
    
    private init() {}
    
    func fetchUser(userId: String) -> UserData? {
        cache[userId]?.toUserData()
    }
    
    func save(userData: UserData) {
        cache[userData.id] = .from(userData)
        try? cache.saveToDisk(withName: Self.cacheName)
    }
}
