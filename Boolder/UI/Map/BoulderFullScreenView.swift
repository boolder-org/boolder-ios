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
    
    @State private var zoomScale: CGFloat = 1
//    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
//    @Environment(\.dismiss) private var dismiss
    
    @Binding var presentFullScreen: Bool
    var animation: Namespace.ID
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    @State private var sheetPresented = false
    
    var body: some View {
        Color.systemBackground
            .opacity(Double(1 - min(abs(dragOffset) / 500, 1)))
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    
                    ZoomableScrollView(zoomScale: $zoomScale) {
                        TopoView(
                            //                    topo: mapState.selectedProblem.topo!,
                            problem: $mapState.selectedProblem,
                            mapState: mapState,
                            zoomScale: $zoomScale,
                            onBackgroundTap: {
                                mapState.showAllStarts = true
                            }
                        )
                    }
                    
                    .matchedGeometryEffect(id: "photo", in: animation, isSource: true)
                    .frame(maxWidth: .infinity)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // greedy to take the full screen
                    .ignoresSafeArea()
                    .offset(y: dragOffset)
                    .gesture(
                        // TODO: use PanGesture like https://www.youtube.com/watch?v=vqPK8qFsoBg
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                dragOffset = gesture.translation.height
                            }
                            .onEnded { gesture in
                                isDragging = false
                                
                                
                                if abs(gesture.translation.height) >= 80 {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                        presentFullScreen = false
                                    }
                                }
                                else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    
                    
                    HStack {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                presentFullScreen = false
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.headline)
                                .frame(width: 18, height: 18)
                                .foregroundColor(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    if !mapState.anyStartSelected {
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
                            
                            
                            let problem = mapState.selectedProblem
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
                    else {
                        HStack(spacing: 16) {
                            Spacer()
                            
                            
                            
                            let problem = mapState.selectedProblem
                            if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
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
            .onChange(of: zoomScale) { oldValue, newValue in
                if newValue < 0.7 {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                        presentFullScreen = false
                    }
                }
            }
            .sheet(isPresented: $sheetPresented) {
                bottomSheet
//                    .presentationDetents([Self.smallDetent, .medium, .large], selection: $selectedDetent)
                    .presentationDetents([.medium, .large])
//                    .presentationBackgroundInteraction(.enabled)
            }
    }
    
    @ViewBuilder
    private var bottomSheet: some View {
        if mapState.anyStartSelected {
            if false { // selectedDetent == Self.smallDetent {
                VStack {
                    Text("xx problems")
                    .padding(.horizontal)
                }
            }
            else {
                List {
                    ForEach(mapState.selectedProblem.otherProblemsOnSameTopo.sorted{ $0.grade < $1.grade }) { p in
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
