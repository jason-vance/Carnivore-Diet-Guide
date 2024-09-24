//
//  Carnivore_Diet_GuideApp.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        setupAdMob()
        DailyUserEngagementService.registerLaunchHandler()
        setupToolbars()
        setup(iocContainer: iocContainer)
        return true
    }
    
    private func setupAdMob() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
#if DEBUG
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "0a0dbc6a509e6ab553770ec5d465ccb9" ]
#endif
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(.banner)
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
        }
    }
}
