//
//  DailyUserEngagementService.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import BackgroundTasks
import Combine
import Foundation
import OSLog
import UserNotifications

class DailyUserEngagementService {
    
    private let lastCheckInKey: String = "lastCheckInKey"
    private let taskId = "com.jasonsapps.carnivoredietguide.fetchContent"
    private let notificationId = "carnivoredietguide.newContentNotification"
    
    private var lastCheckIn: Date {
        get {
            let lastCheckInDouble = UserDefaults.standard.double(forKey: lastCheckInKey)
            return Date(timeIntervalSince1970: lastCheckInDouble)
        }
        set {
            let lastCheckInDouble = newValue.timeIntervalSince1970
            UserDefaults.standard.setValue(lastCheckInDouble, forKey: lastCheckInKey)
        }
    }
    
    private let logger = Logger()
    private let notificationService = NotificationService()
    
    public static let instance: DailyUserEngagementService = {
        .init()
    }()
    
    private init() {
        // Register the background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            self.handleFetchContentTask(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleDailyEngagementReminders() {
        scheduleNewFetchTask()
    }
    
    private var count = 0
    private func scheduleNewFetchTask() {
        let earlyTomorrow = {
            var date = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
            date = Calendar.current.startOfDay(for: date)
            return Calendar.current.date(byAdding: .hour, value: 3, to: date)!
        }()
        
        let request = BGProcessingTaskRequest(identifier: taskId)
        request.earliestBeginDate = earlyTomorrow
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.error("Unable to schedule background task: \(error.localizedDescription)")
        }
    }
    
    private func isLoggedIn() async -> Bool {
        guard let authProvider = iocContainer.resolve(ContentAuthenticationProvider.self) else { return false }
        
        return await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = authProvider.userAuthStatePublisher
                .first()
                .sink { value in
                    continuation.resume(returning: value == .loggedIn)
                    cancellable?.cancel()
                }
        }
    }
    
    private func handleFetchContentTask(task: BGProcessingTask) {
        scheduleNewFetchTask()
        
        Task {
            guard await isLoggedIn() else {
                task.setTaskCompleted(success: true)
                logger.info("Not logged in abandoning fetch operation.")
                return
            }
            
            do {
                let newArticles = try await fetchNewArticles()
                self.sendNotification(newArticles)
                task.setTaskCompleted(success: true)
            } catch {
                logger.error("Unable to handle fetching new content: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    private func fetchNewArticles() async throws -> [Article] {
        guard let articleLibrary = iocContainer.resolve(ArticleLibrary.self) else {
            throw "Couldn't resolve ArticleLibrary"
        }
        
        let lastCheckIn = lastCheckIn
        
        var newestArticles: [Article] = []
        let sub = articleLibrary.publishedArticlesPublisher
            .sink { publishedArticles in
                newestArticles = publishedArticles
                    .filter { $0.publicationDate > lastCheckIn }
            }
        
        try await Task.sleep(for: .seconds(1))
        
        self.lastCheckIn = .now
        return newestArticles
    }
    
    private func sendNotification(_ newArticles: [Article]) {
        notificationService.send(notification: .init(
            identifier: notificationId,
            title: String(localized: "\(newArticles.count) New Article Available"),
            body: String(localized: "Come see what's new!"),
            trigger: .init(timeInterval: 1, repeats: false)
        ))
    }
}
