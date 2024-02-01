//
//  DependencyConfigurator.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation
import Swinject
import SwinjectAutoregistration

let iocContainer: Container = {
    let container = Container()
    setup(iocContainer: container)
    return container
}()

fileprivate func setup(iocContainer: Container) {
    //Content
    iocContainer.autoregister(ContentAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }
    
    //Sign In
    iocContainer.autoregister(SignInAuthenticationProvider.self) { FirebaseAuthenticationProvider.instance }

    //Home
    iocContainer.autoregister(HomeViewContentProvider.self, initializer: FirebaseHomeViewContentProvider.init)
    
    //Recipe Library
    iocContainer.autoregister(RecipeLibraryContentProvider.self, initializer: FirebaseRecipeLibraryContentProvider.init)
    
    //Blog Library
    iocContainer.autoregister(BlogLibraryContentProvider.self, initializer: FirebaseBlogLibraryContentProvider.init)
}
