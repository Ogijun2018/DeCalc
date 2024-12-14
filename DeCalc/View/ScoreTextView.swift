//
//  ScoreTextView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/14.
//

import SwiftUI

/// スコア用のTextView
struct ScoreTextView: View {
    @Binding var point: Int
    @FocusState.Binding var isFocused: Focus?

    var textFieldId: Int

    var body: some View {
        TextField("", value: $point, format: .number)
            .font(.system(size: 20, weight: .bold))
            .focused($isFocused, equals: .focused(id: textFieldId))
            .keyboardType(.numberPad)
    }
}

#Preview {
    @Previewable @State var point: Int = 0
    @FocusState var isFocused: Focus?
    ScoreTextView(
        point: $point,
        isFocused: $isFocused,
        textFieldId: 1
    )
}
