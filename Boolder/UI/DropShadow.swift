//
//  DropShadow.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DropShadow: ViewModifier {
    let visible: Bool
    
    func body(content: Content) -> some View {
        content
            .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(visible ? 0.6 : 0.0), radius: 2)
    }
}
