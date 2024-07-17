//
//  ContentView.swift
//  AppCoordinator
//
//  Created by Ostap Artym on 17.07.2024.
//

import SwiftUI

enum Screen {
    case homeView
    case numberListView
    case numberDetailView(Int)
}

struct NavigationStack<Screen, ScreenView: View>: View {
    @Binding var stack: [Screen]
    @ViewBuilder var buildView: (Screen) -> ScreenView
    
    var body: some View {
        stack
            .enumerated()
            .reversed()
            .reduce(NavigationRouter<Screen, ScreenView>.end) { pushedNode, new in
                let (index, screen) = new
                return NavigationRouter<Screen, ScreenView>.view(
                    buildView(screen),
                    pushing: pushedNode,
                    stack: $stack,
                    index: index
                )
            }
    }
}

indirect enum NavigationRouter<Screen, ScreenView: View>: View {
    case view(ScreenView, pushing: NavigationRouter<Screen, ScreenView>, stack: Binding<[Screen]>, index: Int)
    case end
    
    var body: some View {
        if case .view(let view, let pushedNode, let stack, let index) = self {
            view.background(
                NavigationLink(
                    destination: pushedNode,
                    isActive: Binding(
                        get: {
                            if case .end = pushedNode {
                                return false
                            }
                            return stack.wrappedValue.count > index + 1
                        },
                        set: { isPushed in
                            guard !isPushed else { return }
                            stack.wrappedValue = Array(stack.wrappedValue.prefix(index + 1))
                        }),
                    label: EmptyView.init
                ).hidden()
            )
        } else {
            EmptyView()
        }
    }
}

struct AppCoordinator: View {
    @State var stack: [Screen] = [.homeView]
    
    var body: some View {
        NavigationView {
            NavigationStack(stack: $stack) { screen in
                switch screen {
                case .homeView:
                    HomeView(pickNumberTapped: showNumbers)
                case .numberListView:
                    NumberListView(numberSelected: showNumber)
                case .numberDetailView(let number):
                    NumberDetailView(number: number, cancel: pop, backToMain: backToMain)
                }
            }
        }
    }
    
    private func showNumbers() {
        stack.append(.numberListView)
    }
    
    private func showNumber(_ number: Int) {
        stack.append(.numberDetailView(number))
    }
    
    private func pop() {
        stack = stack.dropLast()
    }
    private func backToMain() {
        stack = [.homeView]
    }
}

struct HomeView: View {
    var pickNumberTapped: () -> Void
    
    var body: some View {
        VStack {
            Text("Home View")
                .font(.largeTitle)
            Button(action: pickNumberTapped) {
                Text("Pick a Number")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}

struct NumberListView: View {
    var numberSelected: (Int) -> Void
    let numbers = Array(1...10) // Список чисел від 1 до 10
    
    var body: some View {
        VStack {
            Text("Number List View")
                .font(.largeTitle)
            List(numbers, id: \.self) { number in
                Button(action: { numberSelected(number) }) {
                    Text("Number \(number)")
                        .font(.title2)
                        .padding()
                }
            }
        }
    }
}

struct NumberDetailView: View {
    let number: Int
    var cancel: () -> Void
    var backToMain: () -> Void
    
    var body: some View {
        VStack {
            Text("Number Detail View")
                .font(.largeTitle)
            Text("Selected Number: \(number)")
                .font(.title)
                .padding()
            
            Button(action: cancel) {
                Text("Back")
                    .font(.title)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button {
                backToMain()
            } label: {
                Text("To home view")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

        }
    }
    

}


struct ContentView: View {
    
    var body: some View {
        AppCoordinator()
    }
}

#Preview {
    ContentView()
}
