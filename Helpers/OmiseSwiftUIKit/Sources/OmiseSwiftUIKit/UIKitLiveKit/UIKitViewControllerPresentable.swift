//
//  UIKitViewControllerPresentable.swift
//  UIKitPreview
//
//  Created by Andrei Solovev on 11/1/23.
//

import SwiftUI
import UIKit

public struct UIKitViewControllerPresentable<VC: UIViewController>: UIViewControllerRepresentable {
    public let viewController: VC

    public func makeUIViewController(context: Context) -> VC {
        viewController
    }

    public func updateUIViewController(_ uiViewController: VC, context: Context) {
//        viewController
    }
}
