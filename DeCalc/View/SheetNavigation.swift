//
//  SheetNavigation.swift
//  DeCalc
//

import SwiftUI

/// シートで表示する画面の共通の枠（タイトル・「完了」ボタン・アクセントカラー）
private struct SheetNavigation: ViewModifier {
  let title: LocalizedStringKey
  @Environment(\.dismiss) private var dismiss

  func body(content: Content) -> some View {
    NavigationStack {
      content
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") { dismiss() }
          }
        }
    }
    .tint(Color.primaryColor)
  }
}

extension View {
  /// シートとして表示する画面に、タイトルと「完了」ボタンのついたナビゲーションを付ける
  func sheetNavigation(title: LocalizedStringKey) -> some View {
    modifier(SheetNavigation(title: title))
  }
}
