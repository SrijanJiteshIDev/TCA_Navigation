//
//  SceneDelegate.swift
//  ExternalActionDemo
//
//  Created by Jitesh Acharya on 20/10/21.
//

import UIKit
import ComposableArchitecture
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        
        let view2State = ViewTwoState(currentScreen: .view2, containerCurrentScreen: .view1)
        
        let view1State = ViewOneState(currentScreen: .view1, containerCurrentScreen: .view1, view2State: view2State)
        
        let containerStore: Store<ContainerState, ContainerActions> = Store(initialState: ContainerState(view1State: view1State, view2State: view2State), reducer: containerReducer, environment: ContainerEnvironment())
        
        let contentView = ContainerView(store: containerStore)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = MyHostingController(
                viewStore: ViewStore(containerStore),
                rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

class MyHostingController<Content>: UIHostingController<Content> where Content : View {
    
    var viewStore: ViewStore<ContainerState, ContainerActions>
        
    init(viewStore: ViewStore<ContainerState, ContainerActions>, rootView: Content) {
        self.viewStore = viewStore
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



