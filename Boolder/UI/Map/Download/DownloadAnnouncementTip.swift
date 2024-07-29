//
//  DownloadAnnouncementTip.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 29/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import TipKit

struct DownloadAnnouncementTip: Tip {
    var id: String = "download.announcement.tip"
    
    var title: Text {
        Text("Nouveau mode hors ligne !")
    }

    var message: Text? {
        Text("C'est ici que ça se passe.")
    }

//    var image: Image? {
//        Image(systemName: "star")
//    }
}
