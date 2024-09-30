//
//  UserFetcher.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 2/11/24.
//

import Foundation
import Combine

class UserFetcher {
    
    private let localFetcher: LocalUserDataFetcher
    private let remoteFetcher: RemoteUserDataFetcher
    
    init(
        localFetcher: LocalUserDataFetcher,
        remoteFetcher: RemoteUserDataFetcher
    ) {
        self.localFetcher = localFetcher
        self.remoteFetcher = remoteFetcher
    }
    
    func fetchUser(userId: String) -> AnyPublisher<UserData, Never> {
        let subject = CurrentValueSubject<UserData?,Never>(nil)
        
        if let userData = localFetcher.fetchUser(userId: userId) {
            subject.send(userData)
        } else {
            Task {
                if let userData = try? await remoteFetcher.fetchUser(userId: userId) {
                    subject.send(userData)
                    localFetcher.save(userData: userData)
                }
            }
        }
        
        return subject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
