//
//  FocusState.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

/// RecordTextFieldのフォーカスを管理するenum
enum Focus: Hashable {
    /// フォーカス中（キーボードが出ている状態）
    /// どのテキストをフォーカスしているかを持つ
    case focused(id: Int)
}
