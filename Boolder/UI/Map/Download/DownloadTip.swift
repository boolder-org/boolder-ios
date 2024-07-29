//
//  DownloadTip.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import TipKit

struct DownloadTip: Tip {
    var id: Int = 1 // TODO: clean up
    
    var title: Text {
        Text("Téléchargez les secteurs en avance")
    }

    var message: Text? {
        Text("Vous éviterez les temps de chargement et vous pourrez utiliser Boolder sans connexion à Internet.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
