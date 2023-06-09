//
//  UIKitViewControllerPresentable.swift
//  UIKitPreview
//
//  Created by Andrei Solovev on 11/1/23.
//

import SwiftUI
import UIKit

struct UIKitViewControllerPresentable<VC: UIViewController>: UIViewControllerRepresentable {
    let viewController: VC

    func makeUIViewController(context: Context) -> VC {
        viewController
    }

    func updateUIViewController(_ uiViewController: VC, context: Context) {
//        viewController
    }
}
