//
//  UIKitViewPresentable.swift
//  UIKitPreview
//
//  Created by Andrei Solovev on 11/1/23.
//

import SwiftUI
import UIKit

public struct UIKitViewPresentable<V: UIView>: UIViewRepresentable {
    public let view: V

    public func makeUIView(context: Context) -> V {
        return view
    }

    public func updateUIView(_ uiView: V, context: Context) {
    }
}
