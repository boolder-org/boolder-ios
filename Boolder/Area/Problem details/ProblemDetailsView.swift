//
//  ProblemDetailsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 25/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemDetailsView: View {
    var problem: ProblemAnnotation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack {
                    Image(uiImage: self.problem.mainTopoPhoto())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    BezierViewRepresentable(problem: problem)
                    
                }
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                    
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(problem.name ?? "-")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                if problem.grade != nil {
                                    Text(problem.grade?.string ?? "")
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                            }
                            
//                            Rectangle()
//                            .fill(Color.green)
//                            .frame(width: 70, height: 4, alignment: .leading)
                        }
//                        .padding(.bottom, 16)
                    
                        
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "arrow.up.right")
                                .font(.body)
                            Text(Steepness(problem.steepness).name)
                                .font(.body)
                            Text("arête, fissure")
                                .font(.caption)
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                        
                        if problem.height != nil {
                        
                            Divider()
                            
                            HStack {
                                Image(systemName: "checkmark.shield")
                                    .font(.body)
                                Text("Hauteur \(problem.height!)m")
                                    .font(.body)
    //                            Text("hauteur : 3m")
    //                                .font(.caption)
    //                                .foregroundColor(Color(UIColor.systemGray))
                                
                                }
                        }
                    }
//                    .padding(0)
                    
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            HStack(alignment: .center, spacing: 16) {
                                Image(systemName: "star")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                Text("Ajouter")
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGreen))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .cornerRadius(8)
                        
                        Button(action: {}) {
                            HStack(alignment: .center, spacing: 16) {
                                Image(systemName: "square")
                                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                Text("Cocher")
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .fixedSize(horizontal: true, vertical: true)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemBackground))
                        .foregroundColor(Color(UIColor.systemGreen))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(UIColor.systemGreen), lineWidth: 2)
                        )
//                        .layoutPriority(1)
                        
                    }
                    .padding(.vertical)
                    
//                    VStack(alignment: .leading) {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Circuit")
//                                .font(.title)
//                                .fontWeight(.bold)
//                            Rectangle()
//                                .fill(Color.green)
//                                .frame(width: 70, height: 4, alignment: .leading)
//                        }
//                    }
//                    .padding(.vertical, 16)
                }
                .padding(.horizontal)
                .padding(.top, 0)
                
                
                
                Spacer()
            }
        }
        .navigationBarTitle(Text(self.problem.name ?? ""), displayMode: .inline)
        .navigationBarItems(trailing:
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                }
//                Button(action: {}) {
//                    Image(systemName: "heart")
//                }
            }
            
        )
    }
}

struct ProblemDetailsView_Previews: PreviewProvider {
    static let dataStore = DataStore()
    
    static var previews: some View {
//        NavigationView {
            ProblemDetailsView(problem: dataStore.annotations.first!)
//        }
    }
}
