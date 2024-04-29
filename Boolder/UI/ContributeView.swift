//
//  ContributeView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 20/03/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContributeView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    Spacer()
                    
                    Text("contribute.title")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("contribute.intro")
                    }
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 40) {
                            Image(systemName: "camera")
                                .foregroundColor(.green)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("contribute.photo")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        
                        HStack(spacing: 40) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("contribute.report")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding()
                    
                    VStack {
                        
                        Button {
                            openURL(contributeURL)
                        } label: {
                            Text("contribute.cta")
                                .font(.body.weight(.semibold))
                                .padding(.vertical)
                        }
                        .buttonStyle(LargeButton())
                        
                        Button {
                            openURL(aboutURL)
                        } label: {
                            Text("contribute.learn_more")
                                .font(.body.weight(.semibold))
                                .padding(.vertical)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            appState.badgeContributeWasSeen = true
            UserDefaults.standard.set(true, forKey: "contribute-badge-was-seen")
        }
    }
    
    var contributeURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/contribute?dismiss_banner=true")!
    }
    
    var aboutURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/about")!
    }
}

#Preview {
    ContributeView()
}
