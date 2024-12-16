//
//  ScoreTextView.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/14.
//

import SwiftUI
import Combine

/// スコア用のTextView
struct ScoreTextView: View {
  @Binding var point: Int
  @FocusState.Binding var isFocused: Focus?
  let maxLength = 4
  var textFieldId: Int

  var body: some View {
    TextField("", value: $point, format: .number)
      .onReceive(Just(point)) { _ in
        // maxLength桁以降の入力を制限
//        let hoge = Int(String(point).prefix(maxLength)) ?? 0
      }
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .padding()
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
