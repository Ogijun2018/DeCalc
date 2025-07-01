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
  var textFieldId: Int
  
  private static let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .none
    formatter.zeroSymbol = ""
    return formatter
  }()

  var body: some View {
    TextField("0", value: $point, formatter: Self.numberFormatter)
      .overlay(
        RoundedRectangle(cornerRadius: 6, style: .continuous)
          .stroke(isFocused == .focused(id: textFieldId) ? Color.primaryColor : Color.gray, lineWidth: 2)
      )
      .textFieldStyle(RoundedBorderTextFieldStyle())
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
