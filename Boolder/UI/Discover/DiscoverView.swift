//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DiscoverView: View {
    @Environment(\.openURL) var openURL

    @State var presentArea = false
    @State private var presentWebView = false
    
    @State private var popularAreas = [Area]()
    @State private var areas = [Area]()
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        VStack {
                            HStack {
                                Button {
                                    presentWebView = true
                                } label: {
                                    
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text("discover.beginners_guide")
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
                                .fullScreenCover(isPresented: $presentWebView) {
                                    SafariWebView(url: URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/articles/beginners-guide")!)
                                        .ignoresSafeArea()
                                    
                                }
                                
                                NavigationLink(destination: TopAreasLevelView()) {
                                    
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
                                
                            }
                            
                            HStack {
                                
                                NavigationLink(destination: TopAreasDryFast()) {
                                    
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
                                
                                NavigationLink(destination: TopAreasTrain()) {
                                    
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
                    }
                    
                    if popularAreas.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            Spacer()
                        }
                        .frame(minHeight: 200)
                    }
                    else {
#if DEVELOPMENT
                        VStack(alignment: .leading) {
                            Text("Dev")
                                .font(.title2).bold()
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading) {
                                Divider()
                                
                                NavigationLink(destination: SettingsView()) {
                                    HStack {
                                        Image(systemName: "gearshape")
                                        Text("Settings")
                                        Spacer()
                                    }
                                    .font(.body)
                                    .foregroundColor(.primary)
                                }
                                
                                Divider()
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
#endif
                        
                        VStack(alignment: .leading) {
                            Text("discover.popular")
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
                                            
                                            ForEach(popularAreas) { area in
                                                NavigationLink {
                                                    AreaView(area: area, linkToMap: true)
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
                                Text("discover.all_areas")
                                    .font(.title2.bold())
                                
                                Spacer()
                                
                            }
                            
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                            .padding(.horizontal)
                            
                            VStack {
                                Divider()
                                
                                ForEach(areas) { area in
                                    
                                    NavigationLink {
                                        AreaView(area: area, linkToMap: true)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(area.name)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(area.problemsCount)").foregroundColor(Color(.systemGray))
                                            
                                            Image(systemName: "chevron.right")
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(.gray.opacity(0.7))
                                            
                                        }
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
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
                                    openURL(contributeURL)
                                }, label: {
                                    HStack {
                                        Image(systemName: "plus.app")
                                        Text("discover.contribute")
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
                }
                .navigationBarTitle(Text("discover.title"))
                .task {
                    popularAreas = Area.all.filter{$0.popular}
                    
                    areas = Area.all.sorted{
                        $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
                    }
                }
            }
        }
        .phoneOnlyStackNavigationView()
    }
    
    var contributeURL: URL {
        if(NSLocale.websiteLocale == "en") {
            return URL(string: "https://www.boolder.com/en/contribute")!
        }
        return URL(string: "https://www.boolder.com/fr/contribute")!
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
