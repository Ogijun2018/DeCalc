//
//  OptionalBinding+Extension.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/14.
//

import SwiftUI

/// See Also: https://stackoverflow.com/questions/57021722/swiftui-optional-textfield
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
