//
//  ViewTwo.swift
//  ExternalActionDemo
//
//  Created by Jitesh Acharya on 20/10/21.
//

import SwiftUI
import ComposableArchitecture

struct ViewTwo: View {
    let store: Store<ViewTwoState, ViewTwoActions>
    @State var push: Bool = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    VStack{
                        Text("Hello, World VIEW 2")
                        Button {
                            viewStore.send(.navigateToView3)
                        } label: {
                            Text("PUSH TO VIEW 3 BUTTON")
                        }
                    }

                    NavigationLink(destination:
                        ViewThrees(store: store.scope(state: \ViewTwoState.viewThreeStates, action: ViewTwoActions.viewThreeAction), id: -1)
                    , isActive: viewStore.binding(get: { $0.currentScreen == .view3
                    }, send: ViewTwoActions.doneWithView3)) {
                        EmptyView()
                    }
                }
            }.navigationBarHidden(true).navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct ViewTwoState: Equatable {
    
    enum View2CurrentScreen{
        case view2
        case view3
    }
    
    var currentScreen:View2CurrentScreen
    var containerCurrentScreen:ContainerState.CurrentScreen
    
    var viewThreeStates:ViewThreeStates = .init(states: [.init(id: 0, containerCurrentScreen: ContainerState.CurrentScreen.view2, view2CurrentScreen: .view3)], containerCurrentScreen: .view2)
    
    var stateOfView3s:ViewThreeStates{
        get{
            var stateOfView3 = self.viewThreeStates
            stateOfView3.containerCurrentScreen = self.containerCurrentScreen
            return stateOfView3
        }
        
        set{
            self.viewThreeStates = newValue
            self.containerCurrentScreen = newValue.containerCurrentScreen
            self.currentScreen = newValue.view2CurrentScreen
        }
    }
}

enum ViewTwoActions {
    case viewThreeAction(ViewThreeStatesActions)
    case navigateToView3
    case doneWithView3
    case none
}

struct ViewTwoEnvironment {}

let viewTwoReducer = Reducer<ViewTwoState, ViewTwoActions, ViewTwoEnvironment>.combine(
    viewThreesReducer.pullback(state: \.stateOfView3s, action: /ViewTwoActions.viewThreeAction, environment: { _ in
        ViewThreeEnvironment()
    }),
    .init { state, action, environ in
        switch action {
        case .navigateToView3:
            state.currentScreen = .view3
            return .none
        case let .viewThreeAction(threeActions):
            return .none
        case .doneWithView3:
            state.currentScreen = .view2
            return .none
        case .none:
            return .none
        }
    }
)
    
    
    
    
    
    
   
