//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import StoreKit
import MapKit

struct ProblemDetailsView: View {
    @AppStorage("problemDetails/viewCount") var viewCount = 0
    @AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
    @Environment(\.requestReview) private var requestReview
    
    @Binding var problem: Problem
    @Environment(MapState.self) private var mapState: MapState
    
    @State private var areaResourcesDownloaded = false
    @State private var presentTopoFullScreenView = false
    
    @State private var variants: [Problem] = []
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        TopoView(
                            problem: $problem,
                            zoomScale: .constant(1),
                            onBackgroundTap: {
                                presentTopoFullScreenView = true
                            }
                        )
                        .fullScreenCover(isPresented: $presentTopoFullScreenView) {
                            TopoFullScreenView(problem: $problem)
                        }
                        
                        variantsMenu
                    }
                    .frame(width: geo.size.width, height: geo.size.width * 3/4)
                    .zIndex(10)
                    
                    ProblemInfoView(problem: problem)
                        .padding(.top, 4)
                        .padding(.horizontal)
                    
                    ProblemActionButtonsView(problem: problem)
                }
            }
            
            Spacer()
        }
        .onAppear {
            computeVariants()
        }
        .onChange(of: problem) {
            computeVariants()
        }
        .onAppear {
            viewCount += 1
        }
        // Inspired by https://developer.apple.com/documentation/storekit/requesting-app-store-reviews
        .onChange(of: viewCount) {
            guard let currentAppVersion = Bundle.currentAppVersion else {
                return
            }

            if viewCount >= 100, currentAppVersion != lastVersionPromptedForReview {
                presentReview()
                lastVersionPromptedForReview = currentAppVersion
            }
        }
    }
    
    var variantsMenu: some View {
        VStack {
            HStack {
                Spacer()
                
                if(variants.count > 1) {
                    Menu {
                        ForEach(variants) { p in
                            Button {
                                mapState.selectProblem(p)
                            } label: {
                                Text("\(p.localizedName) \(p.grade.string)")
                            }
                        }
                    } label: {
                        HStack {
                            Text(String(format: NSLocalizedString("problem.variants", comment: ""), variants.count))
                            Image(systemName: "chevron.down")
                        }
                        .modify {
                            if #available(iOS 26, *) {
                                $0.foregroundColor(.primary)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .glassEffect()
                                    .padding(12)
                            } else {
                                $0
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.gray.opacity(0.8))
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .cornerRadius(16)
                                    .padding(8)
                            }
                        }
                        
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private var paginationText: String {
        let index = variants.firstIndex(of: problem) ?? 0
        let count = variants.count
        return String(format: NSLocalizedString("problem.pagination", comment: ""), index+1, count)
    }
    
    private func computeVariants() {
        variants = problem.variants
    }
    
    private func presentReview() {
        Task {
            // Delay for two seconds to avoid interrupting the person using the app.
            try await Task.sleep(for: .seconds(2))
            requestReview()
        }
    }
}


//struct ProblemDetailsView_Previews: PreviewProvider {
//    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//    static var previews: some View {
//        ProblemDetailsView(problem: .constant(dataStore.problems.first!))
//            .environment(\.managedObjectContext, context)
//    }
//}

