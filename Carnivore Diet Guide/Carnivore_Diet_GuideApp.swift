//
//  Carnivore_Diet_GuideApp.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        DailyUserEngagementService.registerLaunchHandler()
        setupToolbars()
        setup(iocContainer: iocContainer)
        // Start listening for sign-in changes now, so program progress syncs even before the 30 Days tab is opened.
        _ = ProgramStore.instance
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(.banner)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.notification.request.identifier.hasPrefix(ProgramReminderScheduler.identifierPrefix) {
            DispatchQueue.main.async {
                ProgramStore.instance.pendingOpenFromReminder = true
            }
        }
        completionHandler()
    }
    
    fileprivate func setupToolbars() {
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = UIColor(Color.background)
        appearance.shadowColor = UIColor(Color.text)
        
        UIToolbar.appearance().standardAppearance = appearance
    }
}

@main
struct Carnivore_Diet_GuideApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SeedUserCreator.forProd)
                .environmentObject(SeedArticleFavoriter.forProd)
                .environmentObject(SeedRecipeFavoriter.forProd)
                .environmentObject(CommentProxyContainer.shared)
                .environmentObject(ArticleCitationAdder.forProd)
        }
    }
}
