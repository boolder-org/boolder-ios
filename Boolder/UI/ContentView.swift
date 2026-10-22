//
//  ContentView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 28/10/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var mapState = MapState()
    @AppStorage("discover/fireWarningBadgeDismissed") private var fireWarningBadgeDismissed = false
    @State private var presentPremiumIntro = false
    
    var body: some View {
        ZStack {
            TabView(selection: $appState.tab) {
                
                MapContainerView()
                    .tabItem {
                        Label("tabs.map", systemImage: "map")
                    }
                    .tag(AppState.Tab.map)
                
                DiscoverView()
                    .tabItem {
                        Label("tabs.discover", systemImage: "sparkles")
                    }
                    .badge(fireWarningBadgeDismissed ? nil : "")
                    .tag(AppState.Tab.discover)
                
                TickList()
                    .tabItem {
                        Label("tabs.ticklist", systemImage: "bookmark")
                    }
                    .tag(AppState.Tab.ticklist)

                PremiumView()
                    .tabItem {
                        Label("tabs.premium", image: "boolder.logo")
                            .accessibilityValue(Text(premiumAccessibilityValue))
                    }
                    .badge(PremiumStore.shared.hasBillingIssue ? Text(verbatim: "!") : nil)
                    .tag(AppState.Tab.premium)
            }
            .onChange(of: appState.tab) { _, newTab in
                if newTab == .discover {
                    fireWarningBadgeDismissed = true
                }
            }
            
            if #available(iOS 26, *) {
                BottomSheetView(
                    isPresented: $mapState.presentProblemDetails,
                    onSwipeUp: {
                        mapState.requestTopoFullScreenPresentation()
                    }
                ) {
                    ProblemDetailsView()
                }
            }
        }
        .environment(appState)
        .environment(mapState)
        .sheet(isPresented: $presentPremiumIntro) {
            PremiumIntroView(onSeeFreeAreas: { appState.tab = .discover })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task {
            if await PremiumStore.shared.shouldShowIntro(), canPresentPremiumIntro {
                PremiumStore.shared.markIntroSeen()
                presentPremiumIntro = true
            }
        }
    }

    private var canPresentPremiumIntro: Bool {
        appState.tab == .map
            && !mapState.presentProblemDetails
            && !mapState.presentSearch
            && !mapState.presentAreaView
            && !mapState.presentFilters
            && !mapState.presentCircuitPicker
    }

    private var premiumAccessibilityValue: LocalizedStringKey {
        if PremiumStore.shared.hasBillingIssue {
            return "premium.tab.billing_issue"
        }
        return PremiumStore.shared.hasAccess ? "premium.tab.active" : "premium.tab.not_subscribed"
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
