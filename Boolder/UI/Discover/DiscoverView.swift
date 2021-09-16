//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @State var presentArea = false
    @State private var presentAllAreas = false
    @State private var presentSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    VStack {
                        VStack(alignment: .leading) {
                            Text("discover.perfect_for_beginners")
                                .font(.title2).bold()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                    
                                        VStack(alignment: .leading) {
                                            Image("cover-area-13")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                        }
                                        .padding(.leading, 16)
                                        .onTapGesture {
                                            dataStore.areaId = 13
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-area-1")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 1
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-area-14")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 14
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-area-2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 2
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-area-5")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 5
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                        
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
                    
                    #if DEVELOPMENT
                    
                    VStack(alignment: .leading) {
                        Text("DEV MODE")
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
