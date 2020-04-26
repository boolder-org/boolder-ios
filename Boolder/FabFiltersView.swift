//
//  FabFiltersView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 24/04/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct FabFiltersView: View {
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                Button(action: {
                    // do something
                }) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.init(white: 0.8, alpha: 0.6)), lineWidth: 1.0))
                    Text("Circuit")
                }
                
                Divider().frame(width: 1, height: 44, alignment: .center)
                
                Button(action: {
                  print("button tapped")

                }) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filtres")
                    
                }
                .padding(.vertical, 12)
            }
        }
        .accentColor(Color(UIColor.label))
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.25))
        .shadow(color: Color(UIColor.init(white: 0.8, alpha: 0.8)), radius: 8)
        .padding()
        
    }
}

struct FabFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FabFiltersView()
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
