//
//  AreaToolbarView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaToolbarView: View {
    @ObservedObject var mapState: MapState
    
    @State private var presentAreaView = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    mapState.selectedArea = nil
                    mapState.presentProblemDetails = false
                } label: {
                    Image(systemName: "xmark")
                        .font(Font.body.weight(.semibold))
                        .foregroundColor(Color(.secondaryLabel))
                        .padding(.horizontal, 16)
//                        .disabled(true)
                }
                
                Spacer()
                
                Text(mapState.selectedArea?.name ?? "")
//                    .frame(maxWidth: 400)
                    .padding(.vertical, 10)
//                    .padding(.horizontal, 25)
                    .onTapGesture {
                        mapState.presentProblemDetails = false
                        presentAreaView = true
                    }
//                    .background(Color.red)
                
                Button {
                    mapState.presentProblemDetails = false
                    presentAreaView = true
                } label: {
                    Image(systemName: "info.circle")
//                        .background(Color.red)
//                        .foregroundColor(.green)
//                        .padding(.leading, 10)
//                        .disabled(true)
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
            .sheet(isPresented: $presentAreaView) {
                NavigationView {
                    AreaView(viewModel: AreaViewModel(area: mapState.selectedArea!, mapState: mapState))
                }
            }
            
            Spacer()
        }
    }
}

//struct AreaToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaToolbarView()
//    }
//}
