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
    @Environment(\.openURL) var openURL
    
    @State var presentArea = false
    @State var presentArea1 = false
    @State var presentArea9 = false
    @State var presentArea13 = false
    @State var presentArea23 = false
    @State var presentArea24 = false
    @State var presentArea29 = false
    @State var presentArea80 = false
    @State var presentArea81 = false
    @State var presentArea89 = false
    @State var presentArea92 = false // temporary hack to avoid problem with NavigationLink (see below)
    @State var presentArea93 = false
    @State var presentArea94 = false
    @State var presentArea96 = false
    @State var presentArea97 = false
    @State var presentArea98 = false
    @State var presentArea99 = false
    @State var presentArea100 = false
    @State var presentArea101 = false
    @State var presentArea102 = false
    @State var presentArea103 = false
    @State var presentArea107 = false
    @State var presentArea108 = false
    @State var presentArea109 = false
    @State var presentArea110 = false
    @State var presentArea111 = false
    @State var presentArea112 = false
    @State var presentArea113 = false
    @State var presentArea114 = false
    @State var presentArea115 = false
    @State var presentArea116 = false
    @State var presentArea117 = false
    @State var presentArea118 = false
    
    @State private var presentSettings = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                ScrollView {
                    
                    VStack {
                        
                        if searchText.isEmpty {
                            
                            VStack(alignment: .leading) {
                                
//                                VStack {
//                                    HStack {
//                                        NavigationLink(destination: TopAreasLevelView()) {
//
//                                            VStack(alignment: .leading) {
//                                                HStack {
//                                                    Image(systemName: "chart.bar")
//                                                    Text("discover.top_areas.level")
//                                                        .textCase(.uppercase)
//                                                }
//                                                .padding()
//                                                .font(.subheadline.weight(.bold))
//                                                .foregroundColor(Color.white)
//                                                .frame(height: 70)
//                                                .frame(maxWidth: .infinity)
//                                                .background(
//                                                    LinearGradient(gradient:
//                                                                    Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.6)]),
//                                                                   startPoint: .top,
//                                                                   endPoint: .bottom)
//                                                )
//                                                .cornerRadius(8)
//                                            }
//                                        }
//
//                                        NavigationLink(destination: TopAreasGroups()) {
//
//                                            VStack(alignment: .leading) {
//                                                HStack {
//                                                    Image(systemName: "person.3")
//                                                    Text("discover.top_areas.groups")
//                                                        .textCase(.uppercase)
//                                                }
//                                                .padding()
//                                                .font(.subheadline.weight(.bold))
//                                                .foregroundColor(Color.white)
//                                                .frame(height: 70)
//                                                .frame(maxWidth: .infinity)
//                                                .background(
//                                                    LinearGradient(gradient:
//                                                                    Gradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0.6)]),
//                                                                   startPoint: .top,
//                                                                   endPoint: .bottom)
//                                                )
//                                                .cornerRadius(8)
//                                            }
//                                        }
//                                    }
//
//                                    HStack {
//
//                                        NavigationLink(destination: TopAreasDryFast()) {
//
//                                            VStack(alignment: .leading) {
//                                                HStack {
//                                                    Image(systemName: "sun.max")
//                                                    Text("discover.top_areas.dry_fast")
//                                                        .textCase(.uppercase)
//                                                }
//                                                .padding()
//                                                .font(.subheadline.weight(.bold))
//                                                .foregroundColor(Color.white)
//                                                .frame(height: 70)
//                                                .frame(maxWidth: .infinity)
//                                                .background(
//                                                    LinearGradient(gradient:
//                                                                    Gradient(colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.6)]),
//                                                                   startPoint: .top,
//                                                                   endPoint: .bottom)
//                                                )
//                                                .cornerRadius(8)
//                                            }
//                                        }
//
//                                        NavigationLink(destination: TopAreasTrain()) {
//
//                                            VStack(alignment: .leading) {
//                                                HStack {
//                                                    Text("discover.top_areas.train")
//                                                        .textCase(.uppercase)
//                                                }
//                                                .padding()
//                                                .font(.subheadline.weight(.bold))
//                                                .foregroundColor(Color.white)
//                                                .frame(height: 70)
//                                                .frame(maxWidth: .infinity)
//                                                .background(
//                                                    LinearGradient(gradient:
//                                                                    Gradient(colors: [Color.red.opacity(0.2), Color.red.opacity(0.4)]),
//                                                                   startPoint: .top,
//                                                                   endPoint: .bottom)
//                                                )
//                                                .cornerRadius(8)
//                                            }
//                                        }
//                                    }
//                                }
//                                .padding(.horizontal)
//                                .padding(.top)
                                
//                                Text("discover.popular")
//                                    .font(.title2).bold()
//                                    .padding(.top, 16)
//                                    .padding(.bottom, 8)
//                                    .padding(.horizontal)
//
//                                VStack {
//                                    VStack(alignment: .leading) {
//
//                                        ScrollView(.horizontal, showsIndicators: false) {
//                                            HStack(alignment: .top, spacing: 0) {
//
//                                                Color.white.opacity(0)
//                                                    .frame(width: 0, height: 1)
//                                                    .padding(.leading, 8)
//
//                                                ForEach(popularAreas) { area in
//                                                    NavigationLink(
//                                                        destination: AreaView(),
//                                                        isActive: $presentArea,
//                                                        label: {
//                                                            AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
//                                                                .padding(.leading, 8)
//                                                                .contentShape(Rectangle())
//                                                                .onTapGesture {
//                                                                    dataStore.areaId = area.id
//                                                                    dataStore.filters = Filters()
//                                                                    presentArea = true
//                                                                }
//                                                        }
//                                                    )
//                                                }
//
//                                                Color.white.opacity(0)
//                                                    .frame(width: 0, height: 1)
//                                                    .padding(.trailing, 16)
//                                            }
//                                        }
//                                    }
//                                }
                                
                                
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text("Secteurs à mapper")
                                            .font(.title2).bold()
                                        
                                        Spacer()
                                        
//                                        NavigationLink(destination: AllAreasView()) {
//                                            Text("discover.all_areas.map")
//                                        }
                                    }
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    
                                    Divider()
                                    
                                    // bug with foreach & navigation link: https://stackoverflow.com/questions/66017531/swiftui-navigationlink-bug-swiftui-encountered-an-issue-when-pushing-anavigatio
//                                    ForEach(areasDisplayed) { area in
                                    
                                    
//                                        NavigationLink(
//                                            destination: AreaView(),
//                                            isActive: $presentArea92,
//                                            label: {
//                                                HStack {
//                                                    Text("Mont d'Olivet")
//                                                        .font(.body)
//                                                        .foregroundColor(Color.appGreen)
//                                                    Spacer()
//                                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                                }
//                                                .contentShape(Rectangle())
//                                                .onTapGesture {
//                                                    dataStore.areaId = 92
//                                                    dataStore.filters = Filters()
//                                                    presentArea92 = true
//                                                }
//                                            }
//                                        )
//                                        
//                                        Divider()
                                    
//                                    NavigationLink(
//                                        destination: AreaView(),
//                                        isActive: $presentArea93,
//                                        label: {
//                                            HStack {
//                                                Text("Apremont Envers (circuit orange)")
//                                                    .font(.body)
//                                                    .foregroundColor(Color.appGreen)
//                                                Spacer()
//                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                            }
//                                            .contentShape(Rectangle())
//                                            .onTapGesture {
//                                                dataStore.areaId = 93
//                                                dataStore.filters = Filters()
//                                                presentArea93 = true
//                                            }
//                                        }
//                                    )
//                                    
//                                    Divider()
                                    
//                                    NavigationLink(
//                                        destination: AreaView(),
//                                        isActive: $presentArea94,
//                                        label: {
//                                            HStack {
//                                                Text("La Troche")
//                                                    .font(.body)
//                                                    .foregroundColor(Color.appGreen)
//                                                Spacer()
//                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                            }
//                                            .contentShape(Rectangle())
//                                            .onTapGesture {
//                                                dataStore.areaId = 94
//                                                dataStore.filters = Filters()
//                                                presentArea94 = true
//                                            }
//                                        }
//                                    )
//                                    
//                                    Divider()
                                    
//                                    NavigationLink(
//                                        destination: AreaView(),
//                                        isActive: $presentArea96,
//                                        label: {
//                                            HStack {
//                                                Text("Mont Ussy Est")
//                                                    .font(.body)
//                                                    .foregroundColor(Color.appGreen)
//                                                Spacer()
//                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                            }
//                                            .contentShape(Rectangle())
//                                            .onTapGesture {
//                                                dataStore.areaId = 96
//                                                dataStore.filters = Filters()
//                                                presentArea96 = true
//                                            }
//                                        }
//                                    )
//                                    
//                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea97,
                                        label: {
                                            HStack {
                                                Text("La Padole")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 97
                                                dataStore.filters = Filters()
                                                presentArea97 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea98,
                                        label: {
                                            HStack {
                                                Text("La Padole (Cent Marches)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 98
                                                dataStore.filters = Filters()
                                                presentArea98 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
//                                    NavigationLink(
//                                        destination: AreaView(),
//                                        isActive: $presentArea99,
//                                        label: {
//                                            HStack {
//                                                Text("Apremont Sully")
//                                                    .font(.body)
//                                                    .foregroundColor(Color.appGreen)
//                                                Spacer()
//                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                            }
//                                            .contentShape(Rectangle())
//                                            .onTapGesture {
//                                                dataStore.areaId = 99
//                                                dataStore.filters = Filters()
//                                                presentArea99 = true
//                                            }
//                                        }
//                                    )
//                                    
//                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea100,
                                        label: {
                                            HStack {
                                                Text("Monts et Merveilles")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 100
                                                dataStore.filters = Filters()
                                                presentArea100 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
//                                    NavigationLink(
//                                        destination: AreaView(),
//                                        isActive: $presentArea101,
//                                        label: {
//                                            HStack {
//                                                Text("Darvault")
//                                                    .font(.body)
//                                                    .foregroundColor(Color.appGreen)
//                                                Spacer()
//                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                            }
//                                            .contentShape(Rectangle())
//                                            .onTapGesture {
//                                                dataStore.areaId = 101
//                                                dataStore.filters = Filters()
//                                                presentArea101 = true
//                                            }
//                                        }
//                                    )
//                                    
//                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea102,
                                        label: {
                                            HStack {
                                                Text("Troglodyte")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 102
                                                dataStore.filters = Filters()
                                                presentArea102 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea103,
                                        label: {
                                            HStack {
                                                Text("Chamarande")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 103
                                                dataStore.filters = Filters()
                                                presentArea103 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea112,
                                        label: {
                                            HStack {
                                                Text("Chamarande Belvédère (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 112
                                                dataStore.filters = Filters()
                                                presentArea112 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea113,
                                        label: {
                                            HStack {
                                                Text("Bois Rond Auberge")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 113
                                                dataStore.filters = Filters()
                                                presentArea113 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea114,
                                        label: {
                                            HStack {
                                                Text("Justice de Noisy")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 114
                                                dataStore.filters = Filters()
                                                presentArea114 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea115,
                                        label: {
                                            HStack {
                                                Text("Roche aux Sabots Est")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 115
                                                dataStore.filters = Filters()
                                                presentArea115 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea116,
                                        label: {
                                            HStack {
                                                Text("Roche aux Sabots Sud")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 116
                                                dataStore.filters = Filters()
                                                presentArea116 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea117,
                                        label: {
                                            HStack {
                                                Text("Mont Pivot")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 117
                                                dataStore.filters = Filters()
                                                presentArea117 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea118,
                                        label: {
                                            HStack {
                                                Text("Apremont Butte aux Peintres")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 118
                                                dataStore.filters = Filters()
                                                presentArea118 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
//                                    }
                                    
                                    HStack {
                                        Text("Circuits enfants")
                                            .font(.title2).bold()
                                        
                                        Spacer()
                                        
//                                        NavigationLink(destination: AllAreasView()) {
//                                            Text("discover.all_areas.map")
//                                        }
                                    }
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea89,
                                        label: {
                                            HStack {
                                                Text("Franchard Ermitage")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 89
                                                dataStore.filters = Filters()
                                                presentArea89 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea107,
                                        label: {
                                            HStack {
                                                Text("Apremont Bizons (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 107
                                                dataStore.filters = Filters()
                                                presentArea107 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea108,
                                        label: {
                                            HStack {
                                                Text("Apremont (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 108
                                                dataStore.filters = Filters()
                                                presentArea108 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea24,
                                        label: {
                                            HStack {
                                                Text("Saint Germain Est")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 24
                                                dataStore.filters = Filters()
                                                presentArea24 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea109,
                                        label: {
                                            HStack {
                                                Text("Roche aux Sabots (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 109
                                                dataStore.filters = Filters()
                                                presentArea109 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea110,
                                        label: {
                                            HStack {
                                                Text("Feuillardière")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 110
                                                dataStore.filters = Filters()
                                                presentArea110 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea81,
                                        label: {
                                            HStack {
                                                Text("Beauvais Loutteville")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 81
                                                dataStore.filters = Filters()
                                                presentArea81 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea29,
                                        label: {
                                            HStack {
                                                Text("Beauvais Nainville")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 29
                                                dataStore.filters = Filters()
                                                presentArea29 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea80,
                                        label: {
                                            HStack {
                                                Text("Beauvais Télégraphe")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 80
                                                dataStore.filters = Filters()
                                                presentArea80 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea1,
                                        label: {
                                            HStack {
                                                Text("Rocher Canon")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 1
                                                dataStore.filters = Filters()
                                                presentArea1 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea23,
                                        label: {
                                            HStack {
                                                Text("Buthiers Piscine")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 23
                                                dataStore.filters = Filters()
                                                presentArea23 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea13,
                                        label: {
                                            HStack {
                                                Text("Canche aux Merciers")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 13
                                                dataStore.filters = Filters()
                                                presentArea13 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea9,
                                        label: {
                                            HStack {
                                                Text("Elephant")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 9
                                                dataStore.filters = Filters()
                                                presentArea9 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea111,
                                        label: {
                                            HStack {
                                                Text("Buthiers Canard (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 111
                                                dataStore.filters = Filters()
                                                presentArea111 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                    NavigationLink(
                                        destination: AreaView(),
                                        isActive: $presentArea112,
                                        label: {
                                            HStack {
                                                Text("Chamarande Belvédère (enfants)")
                                                    .font(.body)
                                                    .foregroundColor(Color.appGreen)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                            }
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                dataStore.areaId = 112
                                                dataStore.filters = Filters()
                                                presentArea112 = true
                                            }
                                        }
                                    )
                                    
                                    Divider()
                                    
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                
                                
                                
                            }
                            
//                            VStack(alignment: .leading) {
//                                Text("discover.support")
//                                    .font(.title2).bold()
//                                    .padding(.top, 16)
//                                    .padding(.bottom, 8)
//                                    .padding(.horizontal)
//
//                                VStack(alignment: .leading) {
//                                    Divider()
//
//                                    Button(action: {
//                                        let appID = "1506614493"
//                                        let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review"
//                                        guard let url = URL(string: urlStr) else { return }
//                                        openURL(url)
//                                    }, label: {
//                                        HStack {
//                                            Image(systemName: "star")
//                                            Text("discover.rate")
//                                            Spacer()
//                                        }
//                                        .font(.body)
//                                        .foregroundColor(.primary)
//                                    })
//
//                                    Divider()
//
//                                    Button(action: {
//                                        openURL(feedbackURL)
//                                    }, label: {
//                                        HStack {
//                                            Image(systemName: "text.bubble")
//                                            Text("discover.feedback")
//                                            Spacer()
//                                        }
//                                        .font(.body)
//                                        .foregroundColor(.primary)
//                                    })
//
//                                    Divider()
//                                }
//                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
//                                .padding(.horizontal)
//                            }
                            
                            
                            
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
                        else {
                            VStack(alignment: .leading) {
                                
                                Divider()
                                
                                ForEach(searchResults) { area in
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
                    }
                    .navigationBarTitle(Text("Fontainebleau"))
//                    .modify {
//                        if #available(iOS 15, *) {
//                            $0.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: Text("discover.search_prompt"))
//                        }
//                        else {
//                            $0 // no search bar on iOS14
//                        }
//                    }
                }
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
    
    var searchResults: [Area] {
        areasDisplayed.filter { cleanString($0.name).contains(cleanString(searchText)) }
    }
    
    func cleanString(_ str: String) -> String {
        str.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).alphanumeric
    }
    
    var popularAreas: [Area] {
        [4,5,2,1,7,9,10,11,12].map{dataStore.area(withId:$0)!}
    }
    
    var feedbackURL: URL {
        if(NSLocale.websiteLocale == "en") {
            return URL(string: "https://forms.gle/jnnUWyg9tcXtDjZj9")!
        }
        return URL(string: "https://forms.gle/oQVnKU2kUCNP1bZz8")!
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
