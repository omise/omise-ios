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
        NewAtomeFormViewController_Previews.previews
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/// ToDo
///  - ViewController.ViewModel Protocol
///     - viewmodel is optional
///     - Tests for field validator using mostInvalid and cloning pattern
///     - Tests for next button enabled / disabled
///     - Tests for processing (pass data to textfields, press button action - delegate receives data (pass closure to mockup view controller to get callback)
/// - View Model
///     - Dependency injection for Client and use same existing flow
///     - Test using Client's mockup response (postpone but check about future refactoring)

/// Billing address refactoring to the same approach:
///
///  - ViewController.ViewModel Protocol
///     - viewmodel is optional
///     - Tests for field validator using mostInvalid and cloning pattern
///     - Tests for next button enabled / disabled
///     - Tests for processing (pass data to textfields, press button action - delegate receives data (pass closure to mockup view controller to get callback)
/// - View Model
///     - Dependency injection for Client and use same existing flow
///     - Test using Client's mockup response (postpone but check about future refactoring)
