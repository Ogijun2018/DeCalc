//
//  EventTextFieldInfo.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import SwiftUI

/// 一つの種目の入力に必要な情報をまとめたstruct
struct EventTextFieldInfo: Identifiable {
    var id = UUID()
    var event: Event
    var score: Int = 0
}
