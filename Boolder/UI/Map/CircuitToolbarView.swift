//
//  CircuitToolbarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct CircuitToolbarView: View {
    @ObservedObject var mapState: MapState
    
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    mapState.unselectCircuit()
                } label: {
                    Image(systemName: "xmark")
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.horizontal, 16)
//                        .disabled(true)
                }
                
                Spacer()
                
                CircleView(number: "", color: mapState.selectedCircuit?.color.uicolor ?? .gray, height: 20)
                
                Text(mapState.selectedCircuit?.color.longName ?? "")
//                    .frame(maxWidth: 400)
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 25)
                    .onTapGesture {
                        
                    }
//                    .background(Color.red)
                
                Button {
                    mapState.goToNextCircuitProblem()
                } label: {
                    Text("suivant")
                }

                
                
                Spacer()
                
                // quick hack to be able to center the text
                Image(systemName: "chevron.left")
                    .font(Font.body.weight(.semibold))
                    .foregroundColor(Color(.secondaryLabel))
                    .padding(.horizontal, 16)
                    .opacity(0)
                
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

//struct CircuitToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircuitToolbarView()
//    }
//}
