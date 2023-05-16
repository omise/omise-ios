//
//  ContentView.swift
//  OmiseSDKUITests
//
//  Created by Andrei Solovev on 16/5/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        UIKitViewControllerPresentable(viewController: NewAtomeFormViewController())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
