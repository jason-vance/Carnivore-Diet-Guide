//
//  MockDependencyConfigurator.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 1/7/24.
//

import Foundation
import Swinject
import SwinjectAutoregistration

func setupMockIocContainer(_ iocContainer: Container) {
    //Recipe Library
    iocContainer.autoregister(RecipeLibraryContentProvider.self, initializer: MockRecipeLibraryContentProvider.init)
    
    //Blog Library
    iocContainer.autoregister(BlogLibraryContentProvider.self, initializer: MockBlogLibraryContentProvider.init)
}
