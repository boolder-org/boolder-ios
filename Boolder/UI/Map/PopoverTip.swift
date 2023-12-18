//
//  PopoverTip.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/12/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import Foundation
import TipKit

struct PopoverTip: Tip {
    static let shared = PopoverTip()
    
    let id = "PopoverTip" // why is it needed?
    
    @available(iOS 17.0, *)
    static let didTriggerControlEvent = Event(id: "didTriggerControlEvent")
    
    var title: Text {
        Text("Préparez votre sortie")
//            .foregroundStyle(.green)
    }
    var message: Text? {
        Text("Consultez les infos du secteur et téléchargez les photos en hors-ligne.")
    }
    
    @available(iOS 17.0, *)
    var rules: [Rule] {
            [
                // Define a rule based on the user interaction state.
                #Rule(Self.didTriggerControlEvent) {
                    // Set the conditions for when the tip displays.
                    $0.donations.count >= 3
                }
            ]
        }
}
