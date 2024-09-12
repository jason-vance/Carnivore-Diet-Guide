//
//  NotificationService.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/11/24.
//

import Foundation
import UserNotifications

class NotificationService {
    
    struct Notification {
        let identifier: String
        let title: String
        let body: String
        let trigger: UNTimeIntervalNotificationTrigger
    }
    
    func requestPermissions() {
        send(notification: nil)
    }
    
    func send(notification: Notification?) {
        Task {
            do {
                if try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge]) {
                    if let notification = notification {
                        add(notification: notification)
                    }
                } else {
                    print("User denied permissions to send notifications")
                }
            } catch {
                print("Failed to get permissions for notifications. \(error.localizedDescription)")
            }
        }
    }
    
    private func add(notification: Notification) {
        Task {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: notification.identifier, content: content, trigger: notification.trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}
