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
    @Published var capturedPhoto: UIImage? = nil
    @Published var location: CLLocation? = nil
    @Published var heading: CLHeading? = nil
    @Published var comments: String = ""
    @Published var mapModeSelectedProblems = [Problem]()
    @Published var recordMode = false
    
    func reset() {
        capturedPhoto = nil
        location = nil
        heading = nil
        comments = ""
        mapModeSelectedProblems = []
        recordMode = false
    }
}
