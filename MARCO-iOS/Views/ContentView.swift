//
//  ContentView.swift
//  MARCO-iOS
//
//  Created by Jose Castillo on 10/12/22.
//

import Combine
import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    
    // Network shared instance
    @StateObject var network = Network.sharedInstance
    @State var models: [Obra] = []
    @State var rutas: [URL] = []
    
    // Tabbar selection
    @State private var selection = 2
    
    @State var tokens: Set<AnyCancellable> = []
    
    #if !targetEnvironment(simulator)
    // Obra de arte completada
    @StateObject var completed = Coordinator.completed
    #endif
    
    // Light or dark mode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            
        ZStack {
            TabView(selection:$selection) {
                
                ProgressView()
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Progress")
                    }
                    .tag(1)
                #if !targetEnvironment(simulator)
                ZStack {
                    ARViewContainer(models: .constant(self.models))
                        .edgesIgnoringSafeArea(.top)
                    AsyncImage(
                            url: URL(string: ""),
                            content: { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(width: 150)
                                     .offset(CGSize(width: -90, height: -220))
                            },
                            placeholder: {
                                Image("image-placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150)
                                    .offset(CGSize(width: -90, height: -220))
                            }
                        )
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .tag(2)
                #else
                ZStack {
                    Text("AR Screen")
                    AsyncImage(
                            url: URL(string: ""),
                            content: { image in
                                image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(width: 150)
                                     .offset(CGSize(width: -90, height: -220))
                            },
                            placeholder: {
                                Image("image-placeholder")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 150)
                                    .offset(CGSize(width: -90, height: -220))
                            }
                        )
                }
                    .edgesIgnoringSafeArea(.top)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image(systemName: "camera.fill")
                        Text("Camera")
                    }
                    .tag(2)
                #endif
                
                Text("Settings")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(3)
            }
            .accentColor(colorScheme == .dark ? Color.white : Color.black)
            .onAppear {
                // Correct the transparency bug for Tab Bars
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                network.getModels()
                observeModels()
            }
            
            TutorialView()
        }
        #if !targetEnvironment(simulator)
        .sheet(isPresented: $completed.currSheet) {
            ObraView(obra: completed.currModel)
        }
        #endif
    }
    
    // Returns the models when received
    func observeModels() {
        network.obrasPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("Handle \(completion) for error and finished subscription.")
            } receiveValue: { model in
                self.models = model
            }
            .store(in: &tokens)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
