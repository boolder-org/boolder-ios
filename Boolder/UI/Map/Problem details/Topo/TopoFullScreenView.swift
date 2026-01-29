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
    
    // drag gesture (to dismiss the sheet)
    @State var dragOffset: CGSize = .zero
    @State var dragOffsetPredicted: CGSize = .zero
    
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
                            
                            if !showAllLines && problem.otherProblemsOnSameTopo.count > 1 {
                                if #available(iOS 26, *) {
                                    Button(action: { showAllLines = true }) {
                                        Label("problem.topo.all_lines", systemImage: "arrow.trianglehead.clockwise.rotate.90")
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 16), weight: .medium))
                                            .padding(.vertical, 4)
                                    }
                                    .buttonStyle(.glass)
                                    .buttonBorderShape(.capsule)
                                }
                                else {
                                    Button(action: { showAllLines = true }) {
                                        Label("problem.topo.all_lines", systemImage: "arrow.trianglehead.clockwise.rotate.90")
                                            .font(.system(size: UIFontMetrics.default.scaledValue(for: 16), weight: .medium))
                                            .foregroundColor(Color(UIColor.white))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(Color.black.opacity(0.5)))
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    if !showAllLines {
//                        HStack {
//                            Spacer()
//                            VariantsMenuView(problem: $problem)
//                        }
//                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        overlayInfos
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showAllLines)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
                
                ZoomableScrollView(zoomScale: $zoomScale) {
                    TopoView(problem: $problem, zoomScale: $zoomScale, showAllLines: $showAllLines, skipInitialBounceAnimation: true)
                }
                .containerRelativeFrame(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                .zIndex(1)
                .offset(x: 0, y: self.dragOffset.height) // drag gesture
                .background(Color.systemBackground)
                .edgesIgnoringSafeArea(.all)
                
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var overlayInfos: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProblemInfoView(problem: problem)
                .foregroundColor(.primary.opacity(0.8))
            
            ProblemActionButtonsView(problem: $problem, withHorizontalPadding: false)
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
