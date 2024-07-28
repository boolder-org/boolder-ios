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
        Text("Téléchargez vos secteurs préférés")
    }

    var message: Text? {
        Text("Évitez les temps de chargement et utilisez Boolder sans connexion à Internet.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
