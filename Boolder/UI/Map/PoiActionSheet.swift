//
//  PoiActionSheet.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 08/01/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//


import SwiftUI

struct PoiActionSheet: View {
    let name: String
    let googleUrl: URL?
    
    @Environment(\.openURL) var openURL
    @Binding var presentPoiActionSheet: Bool
    
    var body: some View {
        EmptyView()
            .actionSheet(isPresented: $presentPoiActionSheet) {
                ActionSheet(
                    title: Text(name),
                    buttons: buttons
                )
        }
    }
    
    private var buttons : [Alert.Button] {
        var buttons = [Alert.Button]()
        
        if let googleUrl = googleUrl {
            buttons.append(
                .default(Text(
                    String.localizedStringWithFormat(NSLocalizedString("poi.see_in", comment: ""), "Google Maps")
                )) {
                    openURL(googleUrl)
                }
            )
        }
        
        buttons.append(
            .cancel(Text("poi.cancel"))
        )
        
        return buttons
    }
}
