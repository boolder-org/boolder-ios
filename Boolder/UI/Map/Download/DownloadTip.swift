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
        Text("Mode hors connexion")
    }

    var message: Text? {
        Text("Téléchargez les secteurs en avance et utilisez Boolder sans connexion.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
