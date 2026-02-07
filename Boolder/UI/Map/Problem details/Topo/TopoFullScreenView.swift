//
//  TopoFullScreenView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/11/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopoFullScreenView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var problem: Problem
    @Binding var showAllLines: Bool
    
    @State private var zoomScale: CGFloat = 1
    @State private var currentTopo: Topo?
    @State private var toposOnBoulder: [Topo] = []
    @State private var scrollPosition: Int?
    @State private var isAdjustingScroll = false
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = .zero
    @State var dragOffsetPredicted: CGSize = .zero
    
    private var boulder: Boulder? {
        guard let boulderId = problem.topo?.boulderId else { return nil }
        return Boulder(id: boulderId)
    }
    
    // For infinite scroll: [last, ...all, first] so we can loop
    // Index 0 = duplicate of last item
    // Index 1 to count = real items
    // Index count+1 = duplicate of first item
    private var extendedTopos: [(id: Int, topo: Topo, isReal: Bool)] {
        guard toposOnBoulder.count > 1 else { return [] }
        
        var result: [(id: Int, topo: Topo, isReal: Bool)] = []
        
        // Add last topo as first (fake, for looping backward)
        result.append((id: 0, topo: toposOnBoulder.last!, isReal: false))
        
        // Add all real topos
        for (index, topo) in toposOnBoulder.enumerated() {
            result.append((id: index + 1, topo: topo, isReal: true))
        }
        
        // Add first topo as last (fake, for looping forward)
        result.append((id: toposOnBoulder.count + 1, topo: toposOnBoulder.first!, isReal: false))
        
        return result
    }
    
    private var realIndexForCurrentTopo: Int {
        guard let currentTopo = currentTopo else { return 1 }
        return (toposOnBoulder.firstIndex(of: currentTopo) ?? 0) + 1
    }
    
    private var currentTopoIndex: Int {
        guard let currentTopo = currentTopo else { return 0 }
        return toposOnBoulder.firstIndex(of: currentTopo) ?? 0
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    ZStack {
                        HStack {
                            if #available(iOS 26, *) {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                        .padding(4)
                                }
                                .buttonStyle(.glass)
                                .buttonBorderShape(.circle)
                            }
                            else {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(Color(UIColor.white))
                                        .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if !showAllLines {                        
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showAllLines)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                if toposOnBoulder.count > 1 {
                    ZStack {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(extendedTopos, id: \.id) { item in
                                        ZoomableScrollView(zoomScale: $zoomScale) {
                                            TopoView(problem: $problem, zoomScale: $zoomScale, showAllLines: $showAllLines, onBackgroundTap: {
                                                if !showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                                                    showAllLines = true
                                                }
                                            }, skipInitialBounceAnimation: true, displayedTopo: item.topo)
                                        }
                                        .containerRelativeFrame(.horizontal)
                                        .id(item.id)
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.paging)
                            .scrollPosition(id: $scrollPosition)
                            .scrollDisabled(zoomScale > 1.01)
                            .onChange(of: scrollPosition) { oldValue, newValue in
                                guard !isAdjustingScroll, let newPosition = newValue else { return }
                                
                                let count = toposOnBoulder.count
                                
                                // Update current topo based on scroll position
                                if newPosition >= 1 && newPosition <= count {
                                    currentTopo = toposOnBoulder[newPosition - 1]
                                    zoomScale = 1
                                }
                                
                                // Handle infinite loop jump
                                if newPosition == 0 {
                                    // Scrolled to fake last item -> jump to real last
                                    isAdjustingScroll = true
                                    currentTopo = toposOnBoulder.last
                                    zoomScale = 1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        var transaction = Transaction()
                                        transaction.disablesAnimations = true
                                        withTransaction(transaction) {
                                            proxy.scrollTo(count, anchor: .center)
                                            scrollPosition = count
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            isAdjustingScroll = false
                                        }
                                    }
                                } else if newPosition == count + 1 {
                                    // Scrolled to fake first item -> jump to real first
                                    isAdjustingScroll = true
                                    currentTopo = toposOnBoulder.first
                                    zoomScale = 1
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        var transaction = Transaction()
                                        transaction.disablesAnimations = true
                                        withTransaction(transaction) {
                                            proxy.scrollTo(1, anchor: .center)
                                            scrollPosition = 1
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            isAdjustingScroll = false
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                // Jump to initial position without animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    var transaction = Transaction()
                                    transaction.disablesAnimations = true
                                    withTransaction(transaction) {
                                        proxy.scrollTo(realIndexForCurrentTopo, anchor: .center)
                                    }
                                }
                            }
                        }
                        
                        // Page indicator dots
                        VStack {
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(0..<toposOnBoulder.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentTopoIndex ? Color.white : Color.white.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(.bottom, 180)
                        }
                    }
                    .containerRelativeFrame(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    .offset(x: 0, y: self.dragOffset.height)
                    .background(Color.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                } else {
                    ZoomableScrollView(zoomScale: $zoomScale) {
                        TopoView(problem: $problem, zoomScale: $zoomScale, showAllLines: $showAllLines, onBackgroundTap: {
                            if !showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                                showAllLines = true
                            }
                        }, skipInitialBounceAnimation: true)
                    }
                    .containerRelativeFrame(.horizontal)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
                    .offset(x: 0, y: self.dragOffset.height)
                    .background(Color.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                }
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            currentTopo = problem.topo
            if let topo = problem.topo {
                toposOnBoulder = topo.onSameBoulder
            }
        }
    }
    
    var overlayInfos: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProblemInfoView(problem: problem)
                .foregroundColor(.primary.opacity(0.8))
            
            ProblemActionButtonsView(problem: $problem, withHorizontalPadding: false, onCircuitSelected: { dismiss() })
        }
        .padding()
        .frame(minHeight: 150, alignment: .top)
        .modify {
            if #available(iOS 26, *) {
                $0.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
            }
            else {
                $0.background(Color.systemBackground)
            }
        }
    }
}

//struct TopoFullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopoFullScreenView()
//    }
//}
