//
//  DownloadTip.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 04/07/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import TipKit

struct DownloadTip: Tip {
    let id = 1 // FIXME: remove when we target iOS > 15

    var title: Text {
        Text("Téléchargez les secteurs ci-dessous")
    }
    var message: Text? {
        Text("Vous pourrez ensuite utiliser Boolder en mode hors-connexion.")
    }
//    var image: Image? {
//        Image(systemName: "star")
//    }
}
