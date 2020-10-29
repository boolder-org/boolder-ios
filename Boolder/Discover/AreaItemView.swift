//
//  AreaItemView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct AreaItemView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Image("rocher-canon-cover3")
//                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 255, height: 155)
                .cornerRadius(16)
//            Text("Rocher Canon")
//                .font(.body)
            Text("80 voies pour débutants")
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
        .padding(.leading, 16)
    }
}

struct AreaItemView_Previews: PreviewProvider {
    static var previews: some View {
        AreaItemView()
    }
}
