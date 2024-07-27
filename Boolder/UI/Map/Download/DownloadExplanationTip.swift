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
        Text("Téléchargez vos secteurs préférés")
    }

    var message: Text? {
        Text("Vous pourrez éviter le temps de chargement des photos et utiliser Boolder sans connexion à Internet.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
