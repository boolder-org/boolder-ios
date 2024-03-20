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
                    
                    Text("Contribuer à Boolder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Aidez nous à créer le meilleur topo collaboratif pour Fontainebleau !")
                        
//                        Image(systemName: "camera").resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 150)
//                            .padding(.top, 32)
//                            .foregroundColor(.gray)
                        
//                        Text("Notre but est de faciliter la découverte de l’escalade de bloc à Fontainebleau de façon ludique et dans le respect de la forêt.")
//                        Text("Prenez en photo les blocs manquants ou signalez nous les erreurs.")
//                        Text("Merci pour votre aide !")
                    }
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 40) {
                            Image(systemName: "camera")
                                .foregroundColor(.green)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("Prenez le bloc en photo")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }

                        HStack(spacing: 40) {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("Renseignez la position GPS")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        
                        HStack(spacing: 40) {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                                .foregroundColor(.teal)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("Tracez la ligne de la voie")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200, alignment: .leading)
                                .multilineTextAlignment(.leading)
                        }
                        
                        HStack(spacing: 40) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                                .frame(width: 40)
                            
                            Text("Signalez des erreurs")
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
                            Text("Commencer à contribuer")
                                .font(.body.weight(.semibold))
                                .padding(.vertical)
                        }
                        .buttonStyle(LargeButton())
                        
                        Button {
                            openURL(aboutURL)
                        } label: {
                            Text("En savoir plus sur Boolder")
                                .font(.body.weight(.semibold))
                                .padding(.vertical)
                        }
                        //                    .buttonStyle(LargeButton())
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
        .navigationTitle("Contribuer")
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
