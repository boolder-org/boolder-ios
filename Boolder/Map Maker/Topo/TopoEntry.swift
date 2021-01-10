//
//  TopoRecord.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 10/01/2021.
//  Copyright © 2021 Nicolas Mondollot. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

class TopoEntry: ObservableObject {
    @Published var photo: UIImage? = nil
    @Published var location: CLLocation? = nil
    @Published var heading: CLHeading? = nil
    @Published var comments: String = ""
    @Published var problems = [Problem]()
    @Published var pickerModeEnabled = false
    
    func reset() {
        photo = nil
        location = nil
        heading = nil
        comments = ""
        problems = []
        pickerModeEnabled = false
    }
}
