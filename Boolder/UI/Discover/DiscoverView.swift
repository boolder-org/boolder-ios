//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DiscoverView: View {
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    @Environment(\.openURL) var openURL
    
    @State var presentArea = false
    
    @Binding var appTab: ContentView.Tab
    let mapState: MapState
    
    var body: some View {
        NavigationView {
            
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            
                            VStack {
                                HStack {
                                    NavigationLink(destination: TopAreasLevelView(appTab: $appTab, mapState: mapState)) {
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "chart.bar")
                                                Text("discover.top_areas.level")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(Color.white)
                                            .frame(height: 70)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(gradient:
                                                                Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.6)]),
                                                               startPoint: .top,
                                                               endPoint: .bottom)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    NavigationLink(destination: TopAreasGroups(appTab: $appTab, mapState: mapState)) {
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "person.3")
                                                Text("discover.top_areas.groups")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(Color.white)
                                            .frame(height: 70)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(gradient:
                                                                Gradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0.6)]),
                                                               startPoint: .top,
                                                               endPoint: .bottom)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                HStack {
                                    
                                    NavigationLink(destination: TopAreasDryFast(appTab: $appTab, mapState: mapState)) {
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Image(systemName: "sun.max")
                                                Text("discover.top_areas.dry_fast")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(Color.white)
                                            .frame(height: 70)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(gradient:
                                                                Gradient(colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.6)]),
                                                               startPoint: .top,
                                                               endPoint: .bottom)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                    
                                    NavigationLink(destination: TopAreasTrain(appTab: $appTab, mapState: mapState)) {
                                        
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Text("discover.top_areas.train")
                                                    .textCase(.uppercase)
                                            }
                                            .padding()
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(Color.white)
                                            .frame(height: 70)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                LinearGradient(gradient:
                                                                Gradient(colors: [Color.red.opacity(0.2), Color.red.opacity(0.4)]),
                                                               startPoint: .top,
                                                               endPoint: .bottom)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            Text("Populaires")
                                .font(.title2).bold()
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .padding(.horizontal)
                            
                            VStack {
                                VStack(alignment: .leading) {
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top, spacing: 0) {
                                            
                                            Color.white.opacity(0)
                                                .frame(width: 0, height: 1)
                                                .padding(.leading, 8)
                                            
                                            ForEach(popularAreas) { (area: Area) in
//                                                Button {
//                                                    appTab = .map
//                                                    mapState.centerOnArea(area)
//                                                } label: {
//                                                    AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
//                                                        .padding(.leading, 8)
//                                                        .contentShape(Rectangle())
//                                                }
                                                NavigationLink {
                                                    AreaView(area: area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                                } label: {
                                                    AreaCardView(area: area, width: abs(geo.size.width-16*2-8)/2, height: abs(geo.size.width-16*2-8)/2*9/16)
                                                        .padding(.leading, 8)
                                                        .contentShape(Rectangle())
                                                }

                                            }
                                            
                                            Color.white.opacity(0)
                                                .frame(width: 0, height: 1)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                }
                            }
                            
                            
                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Tous les secteurs")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                                Menu {
                                    Button {
                                        // TODO
                                    } label: {
                                        Text("Alphabétique")
                                    }
                                    
                                    Button {
                                        // TODO
                                    } label: {
                                        Text("Nombre de voies")
                                    }

                                } label: {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                }
                            }
                            
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                            
                            VStack {
                                Divider() //.padding(.leading)
                                
                                ForEach(Area.all) { areaWithCount in
                                    
                                    NavigationLink {
                                        AreaView(area: areaWithCount.area, mapState: mapState, appTab: $appTab, linkToMap: true)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(areaWithCount.area.name)
//                                                    .font(.body.weight(.semibold))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
//                                                HStack(spacing: 2) {
//                                                    ForEach(1..<8) { level in
//                                                        Text(String(level))
////                                                            .font(.caption)
//                                                            .frame(width: 20, height: 20)
//                                                            .foregroundColor(.systemBackground)
//                                                            .background(areaWithCount.area.levels[level]! ? Color.levelGreen : Color.gray.opacity(0.5))
//                                                            .cornerRadius(4)
//                                                    }
//                                                }
                                            }

                                            Spacer()
                                            
                                            Text("\(areaWithCount.problemsCount)").foregroundColor(Color(.systemGray))
                                            

                                            
                                            
                                            Image(systemName: "chevron.right").foregroundColor(Color(.systemGray))
                                            
                                        }
                                        .font(.body)
//                                        .frame(minHeight: 32)
                                        .foregroundColor(.primary)
//                                        .background(Color.red)
                                        .padding(.horizontal)
//                                        .padding(.leading)
                                        .padding(.vertical, 4)
                                    }
                                    
                                    
                                    Divider().padding(.leading)
                                }
                            }
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
                                    let appID = "1506614493"
                                    let urlStr = "https://itunes.apple.com/app/id\(appID)?action=write-review"
                                    guard let url = URL(string: urlStr) else { return }
                                    openURL(url)
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
                                    openURL(feedbackURL)
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
                            .padding(.bottom)
                        }
                    }
                    .navigationBarTitle(Text("discover.title"))
                }
            }
        }
        .phoneOnlyStackNavigationView()
    }
    
    var popularAreas: [Area] {
        [5,4,2,1,9,10,11,12].map{Area.load(id: $0)}.compactMap{$0}
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

//struct DiscoverView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiscoverView()
//    }
//}
