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
    @Binding var selectedTab: Int

    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: TabBarController

        init(parent: TabBarController) {
            self.parent = parent
        }
        
        var tabBarController: UITabBarController? {
            didSet {
                print("didSet")
                tabBarController?.selectedIndex = parent.selectedTab
            }
        }
        
        // UITabBarControllerDelegate method
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
                print("Selected tab index: \(index)")
                parent.selectedTab = index
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = viewControllers
        tabBarController.selectedIndex = selectedTab
        
        tabBarController.delegate = context.coordinator

        // Customize the appearance of the tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        tabBarController.tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }

        context.coordinator.parent = self
        context.coordinator.tabBarController = tabBarController

        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = selectedTab
        print("updateUIViewController")
    }
    
    
}
