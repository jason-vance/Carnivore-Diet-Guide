//
//  ResourceDeleter.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 8/26/24.
//

import Foundation
import Combine

protocol ResourceDeleter {
    func delete(resource: Resource) async throws
    var deletedResourcePublisher: AnyPublisher<Resource, Never> { get }
}

class MockResourceDeleter: ResourceDeleter {
    
    public static let instance: MockResourceDeleter = .init()
    public static func getInstance() -> MockResourceDeleter { instance }
    
    private var deletedResourceSubject: CurrentValueSubject<Resource?, Never> = .init(nil)
    public var deletedResourcePublisher: AnyPublisher<Resource, Never> {
        deletedResourceSubject
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    private init() {}
    
    public var error: Error? = nil
    
    func delete(resource: Resource) async throws {
        try await Task.sleep(for: .seconds(1))
        if let error = error {
            throw error
        }
        deletedResourceSubject.send(resource)
    }
}
