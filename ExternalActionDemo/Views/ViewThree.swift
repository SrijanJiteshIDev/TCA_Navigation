//
//  ViewThree.swift
//  ExternalActionDemo
//
//  Created by Jitesh Acharya on 20/10/21.
//

import SwiftUI
import ComposableArchitecture
import IdentifiedCollections

struct ViewThrees:View{
    let store: Store<ViewThreeStates, ViewThreeStatesActions>
    let id:Int

    var body: some View{
            WithViewStore(self.store){ viewStore in
                ZStack{
                    Button {
                        viewStore.send(ViewThreeStatesActions.next(self.id+1))
                    } label: {
                        Text("Next")
                    }.onAppear(perform: { viewStore.send(ViewThreeStatesActions.goneAhead) })
                    
                    NavigationLink(isActive: viewStore.binding(get: { _ in viewStore.goNext.keys.contains(self.id+1) }, send: ViewThreeStatesActions.something(self.id+1)), destination: { ViewThrees(store: store, id: self.id+1) }, label: { EmptyView() })
                }

//                VStack{
//                    ForEachStore(
//                        self.store.scope(state: \.states, action: ViewThreeStatesActions.viewThreeActions(id:action:))
//                    ) { viewThreeStore in
//                        NavigationLink(isActive: viewStore.binding(get: { $0.states.indices.contains($0.currentIndex) }, send: ViewThreeStatesActions.none)) {
//                            ViewThrees(store: store)
//                        } label: {
//                            Text("Hello")
//                        }
//                    }
//                }
            }
    }
}

struct ViewThree: View {
    let store: Store<ViewThreeState, ViewThreeActions>
    var body: some View {
        WithViewStore(self.store) { viewStore in
                ZStack{
                    VStack(spacing: 10) {
                        Text("Hello, World VIEW 3")
                        Button {
                            viewStore.send(.navigateToView1)
                        } label: {
                            Text("POP TO VIEW 1 BUTTON")
                        }
                        Button {
                            viewStore.send(.navigateToView2)
                        } label: {
                            Text("POP TO VIEW 2 BUTTON")
                        }
                        Button {
                            viewStore.send(.pushToSelfNext)
                        } label: {
                            Text("Push itself")
                        }
                    }

                }

        }
    }
}
            

struct ViewThreeStates:Equatable{
    var states:IdentifiedArrayOf<ViewThreeState>
    var containerCurrentScreen:ContainerState.CurrentScreen
    var view2CurrentScreen:ViewTwoState.View2CurrentScreen = .view3
    var currentIndex:Int = 0
    var goNext:Dictionary<Int, Bool> = [:]
    
    var statesForNavigation:IdentifiedArrayOf<ViewThreeState>{
        get{
            return IdentifiedArrayOf<ViewThreeState>(
                uniqueElements: self.states.map { state in
                    var modifiedState = state
                    modifiedState.containerCurrentScreen = self.containerCurrentScreen
                    modifiedState.view2CurrentScreen = self.view2CurrentScreen
                    modifiedState.proceedNext = false
                    return modifiedState
                }
            )
        }
        
        set{
            self.states = newValue
            self.containerCurrentScreen = newValue.last!.containerCurrentScreen
            self.view2CurrentScreen = newValue.last!.view2CurrentScreen
            if (newValue.last!.proceedNext){
                self.states.append(ViewThreeState.init(id: newValue.last!.id + 1, containerCurrentScreen: self.containerCurrentScreen))
                self.currentIndex += 1
            }
        }
    }
}

enum ViewThreeStatesActions{
    case viewThreeActions(id:Int, action:ViewThreeActions)
    case none
    case next(Int)
    case something(Int)
    case goneAhead
}


struct ViewThreeState: Equatable, Identifiable {
    var id:Int
    var containerCurrentScreen:ContainerState.CurrentScreen
    var view2CurrentScreen:ViewTwoState.View2CurrentScreen = .view3
    var proceedNext:Bool = false
}

enum ViewThreeActions {
    case navigateToView1
    case navigateToView2
    case pushToSelfNext
    case none
}

struct ViewThreeEnvironment {}

let viewThreesReducer = Reducer<ViewThreeStates, ViewThreeStatesActions, ViewThreeEnvironment>.combine(
    viewThreeReducer.forEach(state: \ViewThreeStates.statesForNavigation, action: /ViewThreeStatesActions.viewThreeActions, environment: {$0}),
    .init { state, action, env in
        switch action{
        case .next(let index):
//            state.currentIndex += 1
            state.goNext[index] = true
            return .none
        case .goneAhead:
            return .none
        case .something(let index):
            state.goNext.removeValue(forKey: index)
            return .none
        default:
            return .none
        }
    }
)

let viewThreeReducer = Reducer<ViewThreeState, ViewThreeActions, ViewThreeEnvironment>.init { state, action, environ in
    switch action{
    case .navigateToView1:
        state.containerCurrentScreen = .view1
        return .none
    case .navigateToView2:
        state.view2CurrentScreen = .view2
        return .none
    case .pushToSelfNext:
        state.proceedNext = true
        return .none
    case .none:
        return .none
    }
}


