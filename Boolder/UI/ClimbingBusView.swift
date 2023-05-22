//
//  ClimbingBusView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/05/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ClimbingBusView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    Spacer()
                    
                    Image("climbing-bus").resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .padding(.top, 32)
                    
                    Text("bus.title").font(.title.bold())
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("bus.p1")
                        Text("bus.p2")
                        Text("bus.p3")
                        Text("bus.p4")
                    }
                    
                    Button {
                        openURL(URL(string: "https://bit.ly/climbing-bus")!)
                    } label: {
                        Text("Découvrir le Climbing Bus")
                            .font(.body.weight(.semibold))
                            .padding(.vertical)
                    }
                    .buttonStyle(LargeButton())
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            appState.badgeClimbingBusWasSeen = true
            UserDefaults.standard.set(true, forKey: "climbing-bus-badge-was-seen")
        }
        .navigationTitle("Climbing Bus")
    }
}

struct ClimbingBusView_Previews: PreviewProvider {
    static var previews: some View {
        ClimbingBusView()
    }
}
