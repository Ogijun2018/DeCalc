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
  let maxLength = 4
  var textFieldId: Int

  /// pointと相互変換するテキスト。数字以外や空文字は0として扱い、0は空表示にする
  private var text: Binding<String> {
    Binding(
      get: { point == 0 ? "" : String(point) },
      set: { point = Int($0.filter(\.isNumber).prefix(maxLength)) ?? 0 }
    )
  }

  var body: some View {
    TextField("0", text: text)
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
