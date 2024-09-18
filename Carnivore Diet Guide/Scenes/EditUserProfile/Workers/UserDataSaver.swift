//
//  UserDataSaver.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

protocol UserDataSaver {
    func saveOnboarding(userData: UserData) async throws
    func save(userBio: UserBio?, toUser userId: String) async throws
    func save(whyCarnivore: WhyCarnivore?, toUser userId: String) async throws
    func save(carnivoreSince: CarnivoreSince?, toUser userId: String) async throws
}

class MockUserDataSaver: UserDataSaver {
    
    var willThrow = false
    
    func saveOnboarding(userData: UserData) async throws {
        try? await Task.sleep(for: .seconds(1))
        if willThrow { throw TextError("MockUserDataSaver.willThrow = \(willThrow)") }
    }
    
    func save(userBio: UserBio?, toUser userId: String) async throws {
        
    }
    
    func save(whyCarnivore: WhyCarnivore?, toUser userId: String) async throws {
        
    }
    
    func save(carnivoreSince: CarnivoreSince?, toUser userId: String) async throws {
        
    }
}
