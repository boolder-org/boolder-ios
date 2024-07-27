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
        Text("Téléchargez les secteurs en hors connexion")
    }

    var message: Text? {
        Text("Vous pourrez ensuite utiliser toutes les fonctionnalités de Boolder même sans connexion à Internet.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
