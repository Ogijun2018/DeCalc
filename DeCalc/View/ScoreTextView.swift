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

  /// TextFieldの表示文字列。pointとは別に管理し、空文字を確実に0として扱う
  @State private var text: String = ""

  /// pointを表示用文字列へ変換する（0は空表示）
  private var displayText: String {
    point == 0 ? "" : String(point)
  }

  var body: some View {
    TextField("0", text: $text)
      .onChange(of: text) { _, newValue in
        // 数字以外を除去し、maxLength桁までに制限する
        let filtered = String(newValue.filter(\.isNumber).prefix(maxLength))
        if filtered != newValue {
          text = filtered
          return
        }
        // 空文字は0として扱う（テキストを削除して1点が入ってしまう不具合の修正）
        let newPoint = Int(filtered) ?? 0
        if point != newPoint {
          point = newPoint
        }
      }
      .onChange(of: point) { _, _ in
        // 記録からの計算結果や全削除など、外部からのpoint変更を表示へ反映する
        if (Int(text) ?? 0) != point {
          text = displayText
        }
      }
      .onChange(of: isFocused) { _, newValue in
        // フォーカスが外れたら表示を正規化する（先頭の0を除去・0は空表示）
        if newValue != .focused(id: textFieldId) {
          text = displayText
        }
      }
      .onAppear {
        text = displayText
      }
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
