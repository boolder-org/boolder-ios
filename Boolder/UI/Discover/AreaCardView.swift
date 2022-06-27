//
//  AreaCardView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/06/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaCardView: View {
    let area: Area
    let width: CGFloat
    let height: CGFloat
    
    let shadow =    Gradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.1)])
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(area.name)
                    .textCase(.uppercase)
                    .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 0)
            }
            .padding(8)
            .font(.headline.weight(.bold))
            .foregroundColor(Color.white)
            .frame(width: width, height: height)
            .background(
                ZStack {
                    Image("area-cover-\(area.id)").resizable()
                    LinearGradient(gradient: shadow, startPoint: .top, endPoint: .bottom)
                }
            )
            .cornerRadius(8)
        }
    }
}
//
//struct AreaCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AreaCardView()
//    }
//}
