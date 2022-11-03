//
//  AccountView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 02/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

enum DownloadState {
    case initial
    case downloading
    case done
    case error(code: Int, localizedDescription: String)
}

struct AccountView: View {
    @State private var offlineModeActivated = UserDefaults.standard.bool(forKey: "OfflineModeActivated") // TODO: use constant
    @EnvironmentObject var odrManager: ODRManager
    @EnvironmentObject var dataStore: DataStore
    
    @State private var downloadState: DownloadState = .initial
    
    private var allAreasTags: Set<String> {
        // FIXME: don't use dataStore
        let array = dataStore.areas.filter { $0.published }.map{ "area-\($0.id)" }
        return Set(array)
//        return Set(["area-1", "area-2", "area-13", "area-25", "area-26", "area-27"])
    }
    
    func requestTopos() {
        odrManager.requestResources(tags: allAreasTags, onSuccess: {
            downloadState = .done
            print("done")
            
        }, onFailure: { error in
            print("On-demand resource error")
            
            downloadState = .error(code: error.code, localizedDescription: error.localizedDescription)
            
            // FIXME: implement UI, log errors
            switch error.code {
            case NSBundleOnDemandResourceOutOfSpaceError:
                print("You don't have enough space available to download this resource.")
            case NSBundleOnDemandResourceExceededMaximumSizeError:
                print("The bundle resource was too big.")
            case NSBundleOnDemandResourceInvalidTagError:
                print("The requested tag does not exist.")
            default:
                print(error.description)
            }
        })
        
        downloadState = .downloading
    }
    
//    func toposAlreadyRequested() -> Bool {
//
//    }
    
    private var downloadLabel: String {
        switch downloadState {
        case .initial:
            return "-"
        case .downloading:
            return "\(Int(odrManager.downloadProgress*100))%"
        case .done:
            return "100%"
        case .error(code: let code, localizedDescription: let localizedDescription):
            return "Erreur"
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(content: {
                    HStack {
                        Toggle("Offline mode", isOn: $offlineModeActivated)
                            .onChange(of: offlineModeActivated) { value in
                                UserDefaults.standard.set(offlineModeActivated, forKey: "OfflineModeActivated")
                                // UserDefaults.standard.synchronize()
                                if offlineModeActivated {
                                    requestTopos()
                                }
                            }
                    }
                    
                    if offlineModeActivated {
//                        HStack {
//                            Text("Secteurs")
//                            Spacer()
//                            Text("Tous").foregroundColor(.gray)
//                        }.disabled(true)
                        
                        HStack {
                            Text("Téléchargement")
                            Spacer()
                            Text(downloadLabel).foregroundColor(.gray)
                        }
                        
//                        HStack {
//                            Text("Test")
//                            Spacer()
//                            Text("\(odrManager.downloadProgress)%").foregroundColor(.gray)
//                        }
                    }
                },
                footer: {
                    Text("Activez ce mode pour profiter de la carte et des photos de blocs, même sans connectivité.")
                })

                Section {
                    Text("Soutenir Boolder")
                }
            }
            .onAppear {
                
            }
                .navigationTitle("Account")
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
