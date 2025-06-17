//
//  BoulderFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/05/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct BoulderFullScreenView: View {
    @Environment(\.openURL) var openURL
    
    
//    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
//    @Environment(\.dismiss) private var dismiss
    
    @Binding var presentFullScreen: Bool
    var animation: Namespace.ID
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    @State private var sheetPresented = false
    
    @State private var position = ScrollPosition(edge: .top)
    @State private var visibleTopoId: Int?
    
//    let topo: Topo // FIXME: what happens when page changes?
//    var topo: Topo {
//        mapState.selectedProblem.topo!
//    }
    
    
    var body: some View {
        Color.systemBackground
            .opacity(Double(1 - min(abs(dragOffset) / 80, 1)))
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        HStack(spacing: 0) {
                            ForEach(mapState.selection.topo?.onSameBoulder ?? []) { topo in
                                ZoomableTopoView(topo: topo, mapState: mapState, animation: animation)
                                    .id(topo.id)
                            }
                            
                        }
                        .scrollTargetLayout()
                    }
//                    .contentMargins(.horizontal, 8, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition($position)
                    .onScrollPhaseChange { oldPhase, newPhase in
//                                print("\(oldPhase) -> \(newPhase)")
                        
                        if newPhase == .idle && oldPhase != .idle {
                            if let visibleTopoId = visibleTopoId, let topo = Topo.load(id: visibleTopoId) {
                                print("select topo \(visibleTopoId)")
                                mapState.selection = .topo(topo: topo)
                            }
                        }
                    }
                    .onScrollTargetVisibilityChange(idType: Int.self, threshold: 0.8) { ids in
                        visibleTopoId = ids.first
                    }
                    .onChange(of: mapState.selection) { old, new in
                        scrollToCurrent()
                    }
                    .onAppear {
                        print("appear")
                        scrollToCurrent()
                    }
                    
//                    quickSelect
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
//                        .padding(.bottom, 80)
                    
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                presentFullScreen = false
                            }
                        } label: {
                            Image(systemName: "chevron.left")
//                            Image(systemName: "chevron.down")
                                .font(.headline)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Spacer()
                        
                        if case .problem(let problem) = mapState.selection {
                            Text(problem.localizedName)
                            
                            Spacer()
                            
                            // quick hack to center
                            Image(systemName: "chevron.left")
//                            Image(systemName: "chevron.down")
                                .font(.headline)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                                .opacity(0)
                            
                        }
                        

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    switch mapState.selection {
                    case .none:
                        EmptyView()
                    case .topo(topo: let topo):
                        HStack(spacing: 16) {
                            Spacer()
                            
                            Button {
                                sheetPresented = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "list.bullet") // Image(systemName: "arrow.up.forward.app")
                                    Text("Liste")
                                }
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Capsule())
                            }
                            
                            
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    case .start(start: let start):
                        EmptyView()
                    case .problem(problem: let problem):
                        HStack(spacing: 16) {
                            Spacer()
                            
                            Button {
                                // TODO
                            } label: {
                                Image(systemName: "bookmark")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .padding(.horizontal, 2)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            
                            
//                            let problem = mapState.selectedProblem
                            if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
                                Button {
                                    openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "info.circle") // Image(systemName: "arrow.up.forward.app")
                                        Text("Bleau.info")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    
                    
//                    .background(
//                        Rectangle()
//                            .fill(.ultraThinMaterial)
//                            .frame(height: 60)
//                            .overlay(
//                                Rectangle()
//                                    .frame(height: 0.5)
//                                    .foregroundColor(.secondary.opacity(0.3)),
//                                alignment: .bottom
//                            )
//                    )
                    
                    
//                    Button {
//                        // we use a bigger dampingFraction to avoid a weird bug with zoomableScrollView
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
//                            presentFullScreen = false
//                        }
//                        
//                    } label: {
//                        Image(systemName: "xmark")
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                            .padding(8)
//                            .background(.ultraThinMaterial, in: Circle())
//                            .padding(16)
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            )
//            .onChange(of: zoomScale) { oldValue, newValue in
//                if newValue < 0.7 {
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
//                        presentFullScreen = false
//                    }
//                }
//            }
            .sheet(isPresented: $sheetPresented) {
                bottomSheet
//                    .presentationDetents([Self.smallDetent, .medium, .large], selection: $selectedDetent)
                    .presentationDetents([.medium, .large])
//                    .presentationBackgroundInteraction(.enabled)
            }
    }
    
    func scrollToCurrent() {
        
        position.scrollTo(id: mapState.selection.topoId)
    }
    
    @ViewBuilder
    private var quickSelect: some View {
        if let boulderId = mapState.selection.boulderId {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(Boulder(id: boulderId).starts) { p in
                        Button {
                            mapState.selectStartOrProblem(p)
                        } label: {
                            ProblemCircleView(problem: p, isDisplayedOnPhoto: true)
                        }
                    }
                }
                .contentMargins(.horizontal, 8, for: .scrollContent)
            }
        }
    }
    
    @ViewBuilder
    private var bottomSheet: some View {
        if true {
            if false { // selectedDetent == Self.smallDetent {
                VStack {
                    Text("xx problems")
                    .padding(.horizontal)
                }
            }
            else {
                List {
                    ForEach((mapState.selection.topo?.problems ?? []).sorted{ $0.grade < $1.grade }) { p in
                        HStack {
                            ProblemCircleView(problem: p)
                            Text(p.localizedName)
                            Spacer()
                            Text(p.grade.string)
                            
                        }
                        .onTapGesture {
                            sheetPresented = false
                            mapState.selectProblem(p)
                        }
                    }
                }
            }
        }
        else {
            Text("N/A")
        }
    }
}

//#Preview {
//    BoulderFullScreenView()
//}
