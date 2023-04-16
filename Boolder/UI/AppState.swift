//
//  AppState.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 16/04/2023.
//  Copyright © 2023 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

@MainActor class AppState: ObservableObject {
    @Published var selectedProblem: Problem?
}
