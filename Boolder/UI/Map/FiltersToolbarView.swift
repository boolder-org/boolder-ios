//
//  FiltersToolbarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 12/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FiltersToolbarView: View {
    @ObservedObject var mapState: MapState
    @State private var presentAreaView = false
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack {
                Spacer()
                
//                if let area = mapState.selectedArea {
//                    Button(action: {
//                        presentAreaView = true
//                    }) {
//                        Image(systemName: "info")
//                            .padding(12)
//                    }
//                    .accentColor(.primary)
//                    .background(Color.systemBackground)
//                    .clipShape(Circle())
//                    .overlay(
//                        Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
//                    )
//                    .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
//                    .padding(.horizontal)
//                    
//                    .sheet(isPresented: $presentAreaView) {
//                        NavigationView {
//                            AreaView(viewModel: AreaViewModel(area: area))
//                        }
//                    }
//                }
                
                Button(action: {
                    mapState.centerOnCurrentLocation()
                }) {
                    Image(systemName: "location")
                        .padding(12)
                        .offset(x: -1, y: 0)
                }
                .accentColor(.primary)
                .background(Color.systemBackground)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                )
                .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                .padding(.horizontal)
                
                Button(action: {
                    mapState.presentFilters = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .padding(12)
                }
                .accentColor(mapState.filters.filtersCount() >= 1 ? .systemBackground : .primary)
                .background(mapState.filters.filtersCount() >= 1 ? Color.appGreen : .systemBackground)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color(.secondaryLabel), lineWidth: 0.25)
                )
                .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
                .padding(.horizontal)
                
            }
        }
        .padding(.bottom)
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $mapState.presentFilters, onDismiss: {
            mapState.filtersRefresh()
            // TODO: update $mapState.filters only on dismiss
        }) {
            FiltersView(presentFilters: $mapState.presentFilters, filters: $mapState.filters)
                .modify {
                    if #available(iOS 16, *) {
                        $0.presentationDetents([.medium]).presentationDragIndicator(.hidden) // TODO: use heights?
                    }
                    else {
                        $0
                    }
                }
        }
    }
}

//struct FiltersToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        FiltersToolbarView()
//    }
//}
