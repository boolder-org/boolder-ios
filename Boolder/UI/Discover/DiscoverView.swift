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
    @State private var presentFireWarningWebView = false
    
    @State private var popularAreas = [Area]()
    @State private var areas = [Area]()
    
    @Environment(AppState.self) private var appState: AppState
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading) {
                        fireWarningBanner
                            .padding(.horizontal)
                            .padding(.top)

                        quickLinks
                            .padding(.horizontal)
                            .padding(.top, 12)
                    }

                    if popularAreas.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    }
                    else {
                        popularAreasSection(width: geo.size.width)
                        allAreasSection
                        supportSection
#if DEVELOPMENT
                        devSection
#endif
                    }
                }
                .navigationBarTitle(Text("discover.title"))
                .task {
                    popularAreas = Area.popularAreas

                    areas = Area.all.sorted{
                        $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
                    }
                }
            }
        }
        .phoneOnlyStackNavigationView()
    }

    private var quickLinks: some View {
        VStack {
            HStack {
                Button {
                    presentWebView = true
                } label: {
                    DiscoverTile(title: "discover.beginners_guide", colors: [.green.opacity(0.4), .green.opacity(0.6)])
                }
                .fullScreenCover(isPresented: $presentWebView) {
                    SafariWebView(url: URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/articles/beginners-guide")!)
                        .ignoresSafeArea()
                }

                NavigationLink(destination: TopAreasLevelView()) {
                    DiscoverTile(title: "discover.top_areas.level", systemImage: "chart.bar", colors: [.blue.opacity(0.4), .blue.opacity(0.6)])
                }
            }

            HStack {
                NavigationLink(destination: TopAreasDryFast()) {
                    DiscoverTile(title: "discover.top_areas.dry_fast", systemImage: "sun.max", colors: [.yellow.opacity(0.4), .yellow.opacity(0.6)])
                }

                NavigationLink(destination: TopAreasTrain()) {
                    DiscoverTile(title: "discover.top_areas.train", colors: [.red.opacity(0.2), .red.opacity(0.4)])
                }
            }
        }
    }

    private func popularAreasSection(width: CGFloat) -> some View {
        let cardWidth = abs(width-16*2-8)/2

        return VStack(alignment: .leading) {
            sectionTitle("discover.popular")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(popularAreas) { area in
                        NavigationLink {
                            AreaView(area: area, linkToMap: true)
                        } label: {
                            AreaCardView(area: area, width: cardWidth, height: cardWidth*9/16)
                                .padding(.leading, 8)
                                .contentShape(Rectangle())
                        }
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 16)
            }

            if !PremiumStore.shared.hasAccess {
                freeAreasBanner
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
        }
    }

    private var allAreasSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("discover.all_areas", topPadding: 24)

            VStack {
                Divider()

                ForEach(areas) { area in
                    NavigationLink {
                        AreaView(area: area, linkToMap: true)
                    } label: {
                        HStack {
                            Text(area.name)
                                .frame(maxWidth: .infinity, alignment: .leading)

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
    }

    private var supportSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("discover.support")

            linkList {
                Button {
                    openURL(rateURL)
                } label: {
                    linkRow("discover.rate", systemImage: "star")
                }
            }
        }
    }

#if DEVELOPMENT
    private var devSection: some View {
        VStack(alignment: .leading) {
            sectionTitle("Dev")

            linkList {
                NavigationLink(destination: SettingsView()) {
                    linkRow("Settings", systemImage: "gearshape")
                }
            }
        }
    }
#endif

    private func sectionTitle(_ title: LocalizedStringKey, topPadding: CGFloat = 16) -> some View {
        Text(title)
            .font(.title2).bold()
            .padding(.top, topPadding)
            .padding(.bottom, 8)
            .padding(.horizontal)
    }

    private func linkList<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading) {
            Divider()
            content()
            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func linkRow(_ title: LocalizedStringKey, systemImage: String) -> some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
            Spacer()
        }
        .font(.body)
        .foregroundColor(.primary)
    }

    private var fireWarningBanner: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.body)
                .foregroundColor(Color.orange.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("discover.fire_warning")
                    .font(.body)
                    .foregroundColor(Color.orange.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                
                Button {
                    presentFireWarningWebView = true
                } label: {
                    Text("discover.fire_warning.learn_more")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color.appGreen)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.yellow.opacity(0.2))
        .cornerRadius(8)
        .fullScreenCover(isPresented: $presentFireWarningWebView) {
            SafariWebView(url: fireWarningURL)
                .ignoresSafeArea()
        }
    }
    
    private var freeAreasBanner: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.body)
                .foregroundColor(Color.appGreen)

            Text("discover.free_areas")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding()
        .background(Color.appGreen.opacity(0.15))
        .cornerRadius(8)
    }

    private var rateURL: URL {
        URL(string: "https://itunes.apple.com/app/id1506614493?action=write-review")!
    }

    var fireWarningURL: URL {
        if NSLocale.websiteLocale == "en" {
            return URL(string: "https://www-onf-fr.translate.goog/vivre-la-foret/+/2d9a::foret-de-fontainebleau-carte-des-sentiers-et-routes-forestieres-accessibles.html?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en")!
        }
        return URL(string: "https://www.onf.fr/vivre-la-foret/+/2d9a::foret-de-fontainebleau-carte-des-sentiers-et-routes-forestieres-accessibles.html")!
    }
}

private struct DiscoverTile: View {
    let title: LocalizedStringKey
    var systemImage: String? = nil
    let colors: [Color]

    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(title)
                .textCase(.uppercase)
        }
        .padding()
        .font(.subheadline.weight(.bold))
        .foregroundColor(Color.white)
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
        .cornerRadius(8)
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
