//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import StoreKit

struct DiscoverView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    @Environment(\.openURL) var openURL
    
    @State var presentArea = false
    @State private var presentAllAreas = false
    @State private var presentSettings = false
    
    let blue =      Gradient(colors: [Color(red: 191/255, green: 219/255, blue: 254/255), Color(red: 171/255, green: 199/255, blue: 234/255)])
    let green =     Gradient(colors: [Color(red: 167/255, green: 243/255, blue: 208/255), Color(red: 147/255, green: 223/255, blue: 188/255)])
    let pink =      Gradient(colors: [Color(red: 251/255, green: 207/255, blue: 232/255), Color(red: 231/255, green: 187/255, blue: 212/255)])
    let yellow =    Gradient(colors: [Color(red: 253/255, green: 230/255, blue: 138/255), Color(red: 233/255, green: 210/255, blue: 118/255)])
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    VStack {
                        VStack(alignment: .leading) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    NavigationLink(destination: TopAreasLevelView()) {
                                    
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "chart.bar")
                                                Text("discover.top_areas.level")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(.systemBackground))
                                            .frame(width: 200, height: 120)
                                            .background(LinearGradient(gradient: blue, startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: TopAreasGroups()) {
                                    
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "person.3")
                                                Text("discover.top_areas.groups")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(.systemBackground))
                                            .frame(width: 200, height: 120)
                                            .background(LinearGradient(gradient: green, startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: TopAreasTrain()) {
                                    
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("discover.top_areas.train")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(.systemBackground))
                                            .frame(width: 200, height: 120)
                                            .background(LinearGradient(gradient: pink, startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: TopAreasDryFast()) {
                                    
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "sun.max")
                                                Text("discover.top_areas.dry_fast")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(.systemBackground))
                                            .frame(width: 200, height: 120)
                                            .background(LinearGradient(gradient: yellow, startPoint: .top, endPoint: .bottom))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                        .padding(.top)
                        
                        VStack(alignment: .leading) {
                            
                            Text("discover.all_areas")
                                .font(.title2).bold()
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            Divider()

                            ForEach(areasDisplayed) { area in
                                NavigationLink(
                                    destination: AreaView(),
                                    isActive: $presentArea,
                                    label: {
                                        HStack {
                                            Text(area.name)
                                                .font(.body)
                                                .foregroundColor(Color.appGreen)
                                            Text("(\(String(area.problemsCount)))")
                                                .font(.callout)
                                                .foregroundColor(Color(.tertiaryLabel))
                                            Spacer()
                                            Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            dataStore.areaId = area.id
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                )

                                Divider()
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                    }
                    
                    VStack(alignment: .leading) {
                        Text("discover.support")
                            .font(.title2).bold()
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Divider()
                            
                            Button(action: {
                                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                    SKStoreReviewController.requestReview(in: scene)
                                }
                            }, label: {
                                HStack {
                                    Image(systemName: "star")
                                    Text("discover.rate")
                                    Spacer()
                                }
                                .font(.body)
                                .foregroundColor(.primary)
                            })

                            Divider()
                            
                            Button(action: {
                                openURL(URL(string: NSLocalizedString("discover.form_url", comment: ""))!)
                            }, label: {
                                HStack {
                                    Image(systemName: "text.bubble")
                                    Text("discover.feedback")
                                    Spacer()
                                }
                                .font(.body)
                                .foregroundColor(.primary)
                            })

                            Divider()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                    }
                    

                    
                    #if DEVELOPMENT
                    
                    VStack(alignment: .leading) {
                        Text("DEV")
                            .font(.title2).bold()
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading) {
                            Divider()
                            
                            NavigationLink(
                                destination: SettingsView(),
                                isActive: $presentSettings,
                                label: {
                                    HStack {
                                        Text("Settings")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                }
                            )
                            
                            
                            Divider()
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.horizontal)
                    }
                    #endif
                }
                .navigationBarTitle(Text("discover.title"))
            }
        }
        .phoneOnlyStackNavigationView()
    }
    
    var areasDisplayed: [Area] {
        let published = dataStore.areas.filter { $0.published }
        
        var displayed = published
        
        #if DEVELOPMENT
        displayed = dataStore.areas
        #endif
        
        return displayed.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
            
        }
    }
}

// FIXME: there is a weird bug when using StackNavigationViewStyle() on iPhone: the sheets get dismissed automatically the first time they are presented. Sometimes but not always. It seems to happen only when I try to present the sheet a couple of seconds after the app launch, which seems to indicate that the app is not properly loaded? maybe it's still setting up the navigationview "style"?? Anywa, I figured it's easier to just avoid using StackNavigationViewStyle() for now :)
// PLOT TWIST: https://stackoverflow.com/questions/62083810/swiftui-navigation-bar-items-going-haywire-when-swipe-back-fails
extension View {
    func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
