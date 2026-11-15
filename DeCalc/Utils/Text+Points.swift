//
//  Text+Points.swift
//  DeCalc
//

import SwiftUI

extension Text {
  /// 得点を「6543 pt」の形で表示する
  /// 整数をそのまま埋め込むと「6,543」と桁区切りが入り、合計点などの表示とそろわないため、
  /// 文字列にしてから渡す
  init(points: Int) {
    self.init("\(String(points)) pt")
  }
}
