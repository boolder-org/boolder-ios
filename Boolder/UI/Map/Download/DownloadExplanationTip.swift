//
//  DownloadExplanationTip.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import Foundation
import TipKit

struct DownloadExplanationTip: Tip {
    var id: Int = 2 // TODO: clean up
    
    var title: Text {
        Text("Téléchargez les secteurs où vous souhaitez grimper")
    }

    var message: Text? {
        Text("Vous pourrez alors utiliser Boolder en mode hors connexion : c'est plus rapide et ça consomme moins de batterie.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
