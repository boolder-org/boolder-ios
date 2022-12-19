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
    
    var body: some View {
        VStack {
            HStack {
            Text(mapState.selectedArea?.name ?? "")
              .frame(maxWidth: 400)
              .padding(10)
              .padding(.horizontal, 25)
              .overlay(
                HStack {
                    Button {
                        mapState.selectedArea = nil
                        mapState.presentProblemDetails = false
                    } label: {
                        Image(systemName: "chevron.left")
                              .foregroundColor(Color(.secondaryLabel))
                          .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                          .padding(.leading, 10)
                          .disabled(true)
                    }

                  
                }
              )
              .onTapGesture {
                  
              }
              .background(Color(.systemBackground))
              .cornerRadius(12)
              .shadow(color: Color(.secondaryLabel).opacity(0.5), radius: 5)
                
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

//struct AreaToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaToolbarView()
//    }
//}
