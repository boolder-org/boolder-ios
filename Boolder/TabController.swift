//
//  TabController.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 18/05/2024.
//  Copyright © 2024 Nicolas Mondollot. All rights reserved.
//

import SwiftUI
import UIKit

struct TabBarController: UIViewControllerRepresentable {
    let viewControllers: [UIViewController]

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = viewControllers
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        // Update the tab bar controller if needed
    }
}
