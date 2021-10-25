//
//  ViewOne.swift
//  ExternalActionDemo
//
//  Created by Jitesh Acharya on 20/10/21.
//

import SwiftUI
import ComposableArchitecture

struct ViewOne: View {
    let store: Store<ViewOneState, ViewOneActions>
    @State var push: Bool = false
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                ZStack {
                    VStack {
                        Text("Hello, World VIEW 1")
                        
                        Button {
                            viewStore.send(.navigateToView2)
                        } label: {
                            Text("PUSH TO VIEW 2 BUTTON")
                        }
                    }

                    NavigationLink(isActive: viewStore.binding(get: { $0.currentScreen == .view2 }, send: ViewOneActions.navigateToView2)) {
                        ViewTwo(store: store.scope(state: \ViewOneState.stateOfView2, action: ViewOneActions.view2Action))
                    } label: {
                        EmptyView()
                    }

                }
            }
        }
    }
}



struct ViewOneState: Equatable {
    enum View1CurrentScreen{
        case view1
        case view2
    }
    
    var currentScreen:View1CurrentScreen
    var containerCurrentScreen:ContainerState.CurrentScreen
    var view2State: ViewTwoState
    
    var stateOfView2:ViewTwoState{
        get{
            var stateOfView2 = self.view2State
            stateOfView2.containerCurrentScreen = self.containerCurrentScreen
            return stateOfView2
        }
        
        set{
            self.view2State = newValue
            self.containerCurrentScreen = newValue.containerCurrentScreen
        }
    }
    
    
}

enum ViewOneActions {
    case view2Action(ViewTwoActions)
    case navigateToView2
}

struct ViewOneEnvironment {}

let viewOneReducer = Reducer<ViewOneState, ViewOneActions, ViewOneEnvironment>.combine(
    viewTwoReducer.pullback(state: \ViewOneState.stateOfView2, action: /ViewOneActions.view2Action, environment: { _ in
        ViewTwoEnvironment()
    }),
    .init { state, action, environ in
        switch action {
        case .navigateToView2:
            state.view2State.currentScreen = .view2
            state.containerCurrentScreen = .view2
            return .none
        case let .view2Action(twoActions):
            return .none
        }
    }
)
    
    
    
   
