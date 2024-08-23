//
//  Carnivore_Diet_GuideApp.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/1/24.
//

import SwiftUI
import FirebaseCore

//TODO: How do I prevent people from impersonating the "The Carnivore Diet Guide Team" user

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
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
