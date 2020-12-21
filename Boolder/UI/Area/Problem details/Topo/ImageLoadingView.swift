//
//  ImageLoadingView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 21/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ImageLoadingView: View {
    @Binding var progress: Double
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                Text("problem.image.loading").foregroundColor(.gray)
                HStack {
                    Spacer()
                    ProgressView(value: progress)
                        .frame(width: geo.size.width/2, alignment: .center)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct ImageLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoadingView(progress: .constant(0.75))
    }
}
