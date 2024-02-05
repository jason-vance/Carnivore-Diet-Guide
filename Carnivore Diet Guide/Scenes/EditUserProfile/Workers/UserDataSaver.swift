//
//  UserDataSaver.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/4/24.
//

import Foundation

protocol UserDataSaver {
    func save(userData: UserData) async throws
}

class MockUserDataSaver: UserDataSaver {
    
    var willThrow = false
    
    func save(userData: UserData) async throws {
        try? await Task.sleep(for: .seconds(1))
        if willThrow { throw "MockUserDataSaver.willThrow = \(willThrow)" }
    }
}
