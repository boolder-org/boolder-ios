//
//  ProblemListSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/04/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

//
//  DraggableSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 29/03/2025.
//  Copyright © 2025 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemListSheet: View {
    @State private var currentHeight: CGFloat = 130   // Starting height of the sheet
    @State private var dragOffset: CGFloat = 0         // Temporary offset during dragging
    
    @Binding var showAllLines: Bool
    
    @Binding var problem: Problem
    @ObservedObject var mapState: MapState
    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main background content (replace with your content)
//                Color.blue
//                    .ignoresSafeArea()
                
                // The draggable sheet view
                VStack {
                    // A small drag indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(8)
                    
                    VStack {
                        ScrollView {
                            
                            VStack(spacing: 0) {
                                
                                //                                Divider().padding(.vertical, 0)
                                
                                ForEach(problem.topo!.orderedProblems.filter{$0.startId == problem.startId }) { p in
                                    Button {
                                        mapState.selectProblem(p)
                                        showAllLines = false
                                    } label: {
                                        HStack {
                                            ProblemCircleView(problem: p)
                                            Text(p.localizedName)
                                            Spacer()
                                            //                                            if(p.sitStart) {
                                            //                                                Image(systemName: "figure.rower")
                                            //                                            }
                                            
                                            //                                            if(p.featured) {
                                            //                                                Image(systemName: "heart.fill").foregroundColor(.pink)
                                            //                                            }
                                            Text(p.grade.string)
                                        }
                                        .foregroundColor(.primary)
                                        
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                    .background(p.id == problem.id && !showAllLines ? Color.secondary.opacity(0.1) : Color.systemBackground)
                                    
                                    Divider().padding(.vertical, 0)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 5)
                // Adjust the offset so the sheet starts at the bottom with currentHeight visible
                .offset(y: geometry.size.height - currentHeight + dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Update the offset while dragging
                            dragOffset = value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                // If the user drags upward more than 100 points, expand the sheet
                                if -value.translation.height > 20 {
                                    currentHeight = geometry.size.height
                                }
                                // Otherwise, if the user drags downward more than 100 points, collapse
                                else if value.translation.height > 20 {
                                    currentHeight = 130
                                }
                                // Reset temporary drag offset
                                dragOffset = 0
                            }
                        }
                )
                .clipped()
            }
            .onAppear {
                updateHeight()
            }
            .onChange(of: showAllLines) { newValue in
                updateHeight()
            }
//            .overlay(
//                Rectangle()
//                    .frame(height: 1)
//                    .foregroundColor(.gray.opacity(0.3)),
//                alignment: .bottom
//            )
        }
        
        
    }
    
    func updateHeight() {
        if !showAllLines {
            currentHeight = -100
        }
        else {
            currentHeight = 130
        }
    }
}

//struct ProblemListSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        ProblemListSheet()
//    }
//}
