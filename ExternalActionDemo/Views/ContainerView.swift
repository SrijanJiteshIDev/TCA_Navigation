//
//  ContainerView.swift
//  ExternalActionDemo
//
//  Created by Jitesh Acharya on 20/10/21.
//

import SwiftUI
import ComposableArchitecture

struct ContainerView: View {
    let store: Store<ContainerState, ContainerActions>
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    NavigationLink("", destination: ViewOne(store: store.scope(state: \ContainerState.stateForView1, action: ContainerActions.view1Action)).navigationBarHidden(true), isActive: viewStore.binding(get: { $0.currentScreen == .view1}, send: ContainerActions.none))
                    
                    NavigationLink("", destination: ViewTwo(store: store.scope(state: \ContainerState.stateForView2, action: ContainerActions.view2Action)).navigationBarHidden(true), isActive: viewStore.binding(get: { $0.currentScreen == .view2}, send: ContainerActions.none))
                }
            }
        }
    }
}

//struct ContainerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContainerView()
//    }
//}


struct ContainerState: Equatable {
    var view1State: ViewOneState
    var view2State: ViewTwoState
    var currentScreen: CurrentScreen = .view1
    
    enum CurrentScreen {
        case view1
        case view2
    }
    
    var stateForView1:ViewOneState{
        get {
            var stateOfView1 = self.view1State
            stateOfView1.containerCurrentScreen = self.currentScreen
            var stateOfView2 = self.view2State
            stateOfView2.containerCurrentScreen = self.currentScreen
            stateOfView1.stateOfView2 = stateOfView2
            return stateOfView1
        }
        
        set{
            self.view1State = newValue
            self.view2State = newValue.view2State
            self.currentScreen = newValue.containerCurrentScreen
        }
    }
    
    var stateForView2:ViewTwoState{
        get {
            var stateOfView2 = self.view2State
            stateOfView2.containerCurrentScreen = self.currentScreen
            return stateOfView2
        }
        
        set{
            self.view2State = newValue
            self.currentScreen = newValue.containerCurrentScreen
        }
    }
}

enum ContainerActions {
    case view1Action(ViewOneActions)
    case view2Action(ViewTwoActions)
    case navigateToView1
    case navigateToView2
    case none
}

struct ContainerEnvironment {}

let containerReducer = Reducer<ContainerState, ContainerActions, ContainerEnvironment>.combine(
    viewOneReducer.pullback(state: \.stateForView1, action: /ContainerActions.view1Action, environment: { _ in
        ViewOneEnvironment()
    }),
    viewTwoReducer.pullback(state: \.stateForView2, action: /ContainerActions.view2Action, environment: { _ in
        ViewTwoEnvironment()
    }),
    .init { state, action, environ in
        switch action {
        case .navigateToView1:
            state.view1State.currentScreen = .view1
            state.currentScreen = .view1
        case .navigateToView2:
            state.view2State.currentScreen = .view2
            state.currentScreen = .view2
        default: return .none
        }
        return .none
    }
)

