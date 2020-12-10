//
//  HeadingView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import Foundation
import UIKit

class HeadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    func didLoad() {
        backgroundColor = .red
    }
}
