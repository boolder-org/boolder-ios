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
    @State private var presentSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Fontainebleau")
                            .font(.title2).bold()
                        
                        Group {
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("95.2")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 10
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Apremont")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 7
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Canche aux Merciers")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 13
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                        }
                        
                        Group {
                        
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Cul de Chien")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 2
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Cuvier")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 4
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Cuvier Est (Bellevue)")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 6
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                        }
                        
                        Group {
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Éléphant")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 9
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Franchard Isatis")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 5
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                        }
                        
                        Group {
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Franchard Cuisinière")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 11
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                        }
                        
                        Group {
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Gorge aux Châts")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 15
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Roche aux Sabots")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 12
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Rocher Canon")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 1
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                            
                            NavigationLink(
                                destination: AreaView(),
                                isActive: $presentArea,
                                label: {
                                    HStack {
                                        Text("Rocher du Potala")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        dataStore.areaId = 14
                                        dataStore.filters = Filters()
                                        presentArea = true
                                    }
                                }
                            )
                            
                            Divider()
                    
                        }
                        
                        Group {
                            NavigationLink(
                                destination: OtherAreasView(),
                                label: {
                                    HStack {
                                        Text("discover.other_areas")
                                            .font(.body)
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                    }
                                }
                            )
                            
                            Divider()
                        }
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
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
                                            Image("cover-rocher-canon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_for_beginners", comment: ""), String(117))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .padding(.leading, 16)
                                        .onTapGesture {
                                            dataStore.areaId = 1
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-isatis2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_for_beginners", comment: ""), String(90))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 5
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-cul-de-chien2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_for_beginners", comment: ""), String(70))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 2
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
                            Text("discover.great_variety")
                                .font(.title2).bold()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-cuvier2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_over_5", comment: ""), String(420))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 4
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-isatis2")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_over_5", comment: ""), String(393))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 5
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-rocher-canon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text(
                                                String.localizedStringWithFormat(NSLocalizedString("discover.xx_problems_over_5", comment: ""), String(272))
                                            )
                                                .font(.subheadline)
                                                .foregroundColor(Color(.systemGray2))
                                        }
                                        .onTapGesture {
                                            dataStore.areaId = 1
                                            dataStore.filters = Filters()
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                        
                        #if DEVELOPMENT
                        VStack(alignment: .leading) {
                            Divider()
                            
                            NavigationLink(
                                destination: SettingsView(),
                                isActive: $presentSettings,
                                label: {
                                    HStack {
                                        Text("Settings (dev only)")
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
                        .padding(.vertical, 16)
                        #endif
                    }
                }
                .navigationBarTitle(Text("discover.title"))
            }
        }
//        .navigationViewStyle(StackNavigationViewStyle()) // FIXME: there is a weird bug when using StackNavigationViewStyle() on iPhone: the sheets get dismissed automatically the first time they are presented. Sometimes but not always. It seems to happen only when I try to present the sheet a couple of seconds after the app launch, which seems to indicate that the app is not properly loaded? maybe it's still setting up the navigationview "style"?? Anywa, I figured it's easier to just avoid using StackNavigationViewStyle() for now :)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
