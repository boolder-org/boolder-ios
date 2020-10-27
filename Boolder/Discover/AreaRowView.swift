//
//  AreaRowView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaRowView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Idéal pour débuter")
                .font(.title3).bold()
                .padding(.horizontal, 16)
                .padding(.top, 32)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    AreaItemView()
                    AreaItemView()
                    AreaItemView()
                    .padding(.trailing, 16)
                }
            }
//            .frame(height: 185)
//            .padding(.bottom, 10)
        }
    }
}

struct AreaRowView_Previews: PreviewProvider {
    static var previews: some View {
        AreaRowView()
    }
}
