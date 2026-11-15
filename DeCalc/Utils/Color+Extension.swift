//
//  Color+Extension.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/11/28.
//
import SwiftUI

extension Color {
    static let primaryColor = Color("primaryColor")
    static let secondaryColor = Color("secondaryColor")
    /// 画面背景用の淡い青（primaryColorより薄い）
    static let backgroundColor = Color("backgroundColor")

    // 得点内訳グラフで種目の種類を塗り分ける色
    // 赤と緑は色覚特性によって見分けにくくなるため、明るさにも差をつけた組み合わせにしている
    // （1型・2型・3型の色覚シミュレーションで、どの2色も見分けられることを確認済み）
    /// 走種目（青）
    static let runEventColor = Color("runEventColor")
    /// 跳躍種目（赤）
    static let jumpEventColor = Color("jumpEventColor")
    /// 投てき種目（緑）
    static let throwEventColor = Color("throwEventColor")
}
