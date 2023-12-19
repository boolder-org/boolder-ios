//
//  AreaView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import Charts

// we use a separate view to avoid redrawing the entire view and make the actionsheet unresponsive
struct OfflineRowView : View {
    let area: Area
    
    @ObservedObject var offlineArea: OfflineArea
    @Binding var presentRemoveDownloadSheet: Bool
    @Binding var presentCancelDownloadSheet: Bool
    
    init(area: Area, presentRemoveDownloadSheet: Binding<Bool>, presentCancelDownloadSheet: Binding<Bool>) {
        self.area = area
        self.offlineArea = OfflinePhotosManager.shared.offlineArea(withId: area.id)
        self._presentRemoveDownloadSheet = presentRemoveDownloadSheet
        self._presentCancelDownloadSheet = presentCancelDownloadSheet
    }
    
//    init(presentRemoveDownloadSheet: Binding<Bool>, presentCancelDownloadSheet: Binding<Bool>) {
//        self.offlineArea = OfflinePhotosManager.shared.offlineArea(withId: area.id)
//        self.presentRemoveDownloadSheet = .constant(true)
//        self.presentCancelDownloadSheet = .constant(true)
//    }
    
    var body: some View {
        let _ = Self._printChanges()
        Button {
            if case .initial = offlineArea.status  {
                // FIXME: refactor
                OfflinePhotosManager.shared.requestArea(areaId: offlineArea.areaId)
                offlineArea.download()
            }
            else if case .downloading(_) = offlineArea.status  {
                presentCancelDownloadSheet = true
            }
            else if case .downloaded = offlineArea.status  {
                presentRemoveDownloadSheet = true
            }
        } label: {
            HStack {
//                            Image(systemName: "photo").foregroundColor(.primary)
                Text("Photos hors-ligne").foregroundColor(.primary)
                Spacer()
                
                if case .initial = offlineArea.status  {
                    Image(systemName: "arrow.down.circle").resizable().aspectRatio(contentMode: .fit).frame(height: 20).foregroundColor(.appGreen)
                }
                else if case .downloading(let progress) = offlineArea.status  {
                    CircularProgressView(progress: progress).frame(height: 18)
                }
                else if case .downloaded = offlineArea.status  {
                    Image(systemName: "checkmark.circle").resizable().aspectRatio(contentMode: .fit).frame(height: 22).foregroundColor(.appGreen)
                }
                else {
                    Text(offlineArea.status.label)
                }
            }
        }
    }
}

struct AreaView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    
    let area: Area
    @EnvironmentObject var appState: AppState
    let linkToMap: Bool
    
//    @ObservedObject private var odrManager = ODRManager()
//    @State private var offlineMode = false
//    @State private var areaResourcesDownloaded = false
//    @ObservedObject var offlineArea: OfflineArea // FIXME: make instantiation DRY
    
    @State private var presentRemoveDownloadSheet = false
    @State private var presentCancelDownloadSheet = false
    
    @State private var circuits = [Circuit]()
    @State private var popularProblems = [Problem]()
    @State private var showChart = false
    @State private var chartData: [Level] = []
    @State private var poiRoutes = [PoiRoute]()
    
    var body: some View {
        let _ = Self._printChanges()
        ZStack {
            List {
                if area.tags.count > 0 || area.descriptionFr != nil || area.warningFr != nil {
                    Section {
                        tagsWithFlowLayout
                        descriptionAndWarning
                    }
                }
                
                problems
                    
                
                if(circuits.count > 0) {
                    circuitsList
                }
                
                if poiRoutes.count > 0 {
                    poiRoutesList
                }
                
                Section {
                    
                    OfflineRowView(area: area, presentRemoveDownloadSheet: $presentRemoveDownloadSheet, presentCancelDownloadSheet: $presentCancelDownloadSheet)
                        .background {
                            EmptyView().actionSheet(isPresented: $presentRemoveDownloadSheet) {
                                ActionSheet(
                                    title: Text("Supprimer les photos hors-ligne ?"),
                                    buttons: [
                                        .destructive(Text("Supprimer")) {
                                            OfflinePhotosManager.shared.offlineArea(withId: area.id).remove()
                                        },
                                        .cancel()
                                    ]
                                )
                            }
                        }
                        .background {
                            EmptyView().actionSheet(isPresented: $presentCancelDownloadSheet) {
                                ActionSheet(
                                    title: Text("Annuler téléchargement ?"),
                                    buttons: [
                                        .destructive(Text("Annuler téléchargement")) {
                                            OfflinePhotosManager.shared.offlineArea(withId: area.id).cancel()
                                        },
                                        .cancel() // TODO: wording?
                                    ]
                                )
                            }
                        }
                    
                    
                }
                
                if(linkToMap) {
                    // leave room for sticky footer
                    Section(header: Text("")) {
                        EmptyView()
                    }
                    .padding(.bottom, 24)
                }
            }
            
            if(linkToMap) {
                VStack {
                    Spacer()
                    
                    Button {
                        appState.selectedArea = area
                        appState.tab = .map
                    } label: {
                        Text("area.see_on_the_map")
                            .font(.body.weight(.semibold))
                            .padding(.vertical)
                    }
                    .buttonStyle(LargeButton())
                    .padding()
                }
            }

        }
        .onAppear {
            circuits = area.circuits
            popularProblems = area.popularProblems
            
            chartData = [
                .init(name: "1", count: min(150, area.level1Count)),
                .init(name: "2", count: min(150, area.level2Count)),
                .init(name: "3", count: min(150, area.level3Count)),
                .init(name: "4", count: min(150, area.level4Count)),
                .init(name: "5", count: min(150, area.level5Count)),
                .init(name: "6", count: min(150, area.level6Count)),
                .init(name: "7", count: min(150, area.level7Count)),
                .init(name: "8", count: min(150, area.level8Count)),
            ]
            
            poiRoutes = area.poiRoutes
        }
        .navigationTitle(area.name)
        .navigationBarTitleDisplayMode(.inline)
        .modify {
            if(linkToMap) {
                $0
            }
            else {
                $0.navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("area.close")
                            .padding(.vertical)
                            .font(.body)
                    }
                )
            }
        }
        
    }
    
    var tags: some View {
        ForEach(area.tags, id: \.self) { tag in
            Text(NSLocalizedString("area.tags.\(tag)", comment: ""))
                .font(.callout)
                .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
//                .foregroundColor(Color(UIColor.darkGray))
                .background(Color.systemBackground)
                .cornerRadius(32)
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color(UIColor.darkGray), lineWidth: 1.0))
        }
    }
    
    var tagsWithFlowLayout: some View {
        Group {
            if area.tags.count > 0 {
                if #available(iOS 16.0, *) {
                    Group {
                        FlowLayout(alignment: .leading) {
                            tags
                        }
//                        .padding(.vertical, 4)
                    }
                }
                else {
                    Group {
                        VStack(alignment: .leading) {
                            tags
                        }
//                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
    
    var descriptionAndWarning: some View {
        Group {
            if area.descriptionFr != nil || area.warningFr != nil {
                if let descriptionFr = area.descriptionFr, let descriptionEn = area.descriptionEn {
                    VStack(alignment: .leading) {
                        Text(NSLocale.websiteLocale == "fr" ? descriptionFr : descriptionEn)
                    }
                }
                
                if let warningFr = area.warningFr, let warningEn = area.warningEn {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocale.websiteLocale == "fr" ? warningFr : warningEn).foregroundColor(.orange)
                    }
                }
            }
        }
    }
    
    var problems: some View {
        Section {
            VStack {
                Button {
                    showChart.toggle()
                } label: {
                    HStack {
                        Text("area.levels")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        AreaLevelsBarView(area: area)
                    }
                }

                if showChart {
                    if #available(iOS 16.0, *) {
                        Chart {
                            ForEach(chartData) { shape in
                                BarMark(
                                    x: .value("area.chart.level", shape.name),
                                    y: .value("area.chart.problems", shape.count)
                                )
                            }
                        }
                        .chartYScale(domain: 0...150)
                        .foregroundColor(.levelGreen)
                        .frame(height: 150)
                        .padding(.vertical)
                        .clipShape(Rectangle())
                    }
                }
            }
            
            NavigationLink {
                AreaProblemsView(area: area)
            } label: {
                HStack {
                    Text("area.problems")
                    Spacer()
                    Text("\(area.problemsCount)")
                }
            }
        }
    }
    
    var circuitsList: some View {
        Section {
            ForEach(circuits) { circuit in
                NavigationLink {
                    CircuitView(area: area, circuit: circuit)
                } label: {
                    HStack {
                        CircleView(number: "", color: circuit.color.uicolor, height: 20)
                        Text(circuit.color.longName)
                        Spacer()
                        if(circuit.beginnerFriendly) {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                        if(circuit.dangerous) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.orange)
                                .font(.title3)
                        }
                        Text(circuit.averageGrade.string)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
    
    var poiRoutesList: some View {
        Section(header: Text("Accès")) {
            ForEach(poiRoutes) { poiRoute in
                if let poi = poiRoute.poi {
                    
                    Button {
                        if let url = URL(string: poi.googleUrl) {
                            openURL(url)
                        }
                    } label: {
                        HStack {
                            if poi.type == .parking {
                                Image(systemName: "p.square.fill")
                                    .foregroundColor(Color(UIColor(red: 0.16, green: 0.37, blue: 0.66, alpha: 1.00)))
                                    .font(.title2)
                            }
                            else if poi.type == .trainStation {
                                Image(systemName: "tram.fill")
                                    .font(.body)
                            }
                            
                            Text(poi.shortName)
                            
                            Spacer()
                            
                            if poiRoute.transport == .bike {
                                Image(systemName: "bicycle")
                            }
                            else {
                                Image(systemName: "figure.walk")
                            }
                            
                            Text("\(poiRoute.distanceInMinutes) min")
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    struct Level: Identifiable {
        var name: String
        var count: Int
        var id = UUID()
    }
}

//struct AreaView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaView(viewModel: AreaViewModel(areaId: 1))
//    }
//}
