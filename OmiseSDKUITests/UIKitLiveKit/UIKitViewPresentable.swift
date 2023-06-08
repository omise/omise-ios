//
//  UIKitViewPresentable.swift
//  UIKitPreview
//
//  Created by Andrei Solovev on 11/1/23.
//

import SwiftUI
import UIKit

struct UIKitViewPresentable<V: UIView>: UIViewRepresentable {
    let view: V

    func makeUIView(context: Context) -> V {
        return view
    }

    func updateUIView(_ uiView: V, context: Context) {
    }
}
