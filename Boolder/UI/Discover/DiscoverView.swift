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
                                        NavigationLink(
                                            destination: AreaView(),
                                            isActive: $presentArea,
                                            label: {
                                                HStack {
                                                    Text("Mont d'Olivet")
                                                        .font(.body)
                                                        .foregroundColor(Color.appGreen)
                                                    Spacer()
                                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    dataStore.areaId = 92
                                                    dataStore.filters = Filters()
                                                    presentArea = true
                                                }
                                            }
                                        )
                                        
                                        Divider()
//                                    }
                                    
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
