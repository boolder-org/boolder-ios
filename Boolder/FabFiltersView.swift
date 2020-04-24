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
                    // do someting
                }) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 22, height: 22)
                        .cornerRadius(6)
                    Text("Circuit")
                }
                
                Divider().frame(width: 1, height: 44, alignment: .center)
                
                Button(action: {
                  print("button pressed")

                }) {
                    Image(systemName: "slider.horizontal.3")
//                        .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                    Text("Filtres")
                    
                }
                .padding(.vertical, 11)
//                .layoutPriority(1)
            }
        }
        .accentColor(Color.black)
//        .frame(height: 44, alignment: .center)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 8)
        .padding()
        
    }
}

struct FabFiltersView_Previews: PreviewProvider {
    static var previews: some View {
        FabFiltersView()
    }
}
