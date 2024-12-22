//
//  EventInfo.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import Foundation
/// 混成種目が持つ一種目の情報を持つstruct
struct EventInfo: Identifiable, Hashable {
  var id = UUID()
  var idForScore = UUID()
  /// 種目
  var event: Event
  /// 一種目の記録
  var score: String?
  /// 一種目の点数
  var point: Int = 0
  /// 種目の最大点数（理論値）
  var maxPoint: Int {
    switch event {
    case .Run:
      // 0.01s
      return Int(event.firstCoefficient * pow(event.secondCoefficient - 0.01, event.thirdCoefficient))
    case .Jump:
      // 9m99cm
      return Int(event.firstCoefficient * pow(Double(999) - event.secondCoefficient, event.thirdCoefficient))
    case .Throw:
      // 99m99cm
      return Int(event.firstCoefficient * pow(event.secondCoefficient - 99.99, event.thirdCoefficient))
    }
  }

  /// エラーテキスト
  var errorText: String?

  func convertToScore(point: Int) throws -> Int {
    switch event {
    case .Run:
      if try convertToPoint(score: 0001) < point {
        throw CalculationError.overPoint
      }
      // 逆計算でscoreを求める
      let doublePoint = Double(point)
      let score = event.secondCoefficient - pow(doublePoint / event.firstCoefficient, 1 / event.thirdCoefficient)
      if score.isNaN || score.isInfinite {
        throw CalculationError.invalidResult
      } else if score < 0 {
        // TODO: スコア0未満の場合のerror
        throw CalculationError.invalidResult
      }
      return convertScoreToInt(seconds: score)
    case .Jump:
      if try convertToPoint(score: 999) < point {
        throw CalculationError.overPoint
      }
      // 逆計算でscoreを求める
      let doublePoint = Double(point)
      let score = event.secondCoefficient + pow(doublePoint / event.firstCoefficient, 1 / event.thirdCoefficient)
      if score.isNaN || score.isInfinite {
        throw CalculationError.invalidResult
      } else if score < 0 {
        // TODO: スコア0未満の場合のerror
        throw CalculationError.invalidResult
      }
      // 跳躍種目の場合はcmのままなので四捨五入を行う
      return Int(round(score))
    case .Throw:
      if try convertToPoint(score: 9999) < point {
        throw CalculationError.overPoint
      }
      // 逆計算でscoreを求める
      let doublePoint = Double(point)
      let score = event.secondCoefficient + pow(doublePoint / event.firstCoefficient, 1 / event.thirdCoefficient)
      if score.isNaN || score.isInfinite {
        throw CalculationError.invalidResult
      } else if score < 0 {
        // TODO: スコア0未満の場合のerror
        throw CalculationError.invalidResult
      }
      // 投擲種目はcmを100倍し四捨五入を行う
      return Int(round(score * 100))
    }
  }

  /// 混成競技の得点計算方法
  /// ref: https://games.athleteranking.com/faq/faq07.php
  func convertToPoint(score: Int) throws -> Int {
    switch event {
    case .Run:
      // 記録をDoubleの値に変換する
      let hoge = convertScoreToDouble(score: score)
      let result = event.firstCoefficient * pow(event.secondCoefficient - hoge, event.thirdCoefficient)
      if result.isNaN || result.isInfinite {
        throw CalculationError.invalidResult
      }
      return Int(result)
    case .Jump:
      // 跳躍種目はcm単位のため、入力された値のまま
      let result = event.firstCoefficient * pow(Double(score) - event.secondCoefficient, event.thirdCoefficient)
      if result.isNaN || result.isInfinite {
        throw CalculationError.invalidResult
      }
      return Int(result)
    case .Throw:
      // 投擲種目はm単位のため、入力された値を変換する
      let hoge = convertScoreToDouble(score: score)
      let result = event.firstCoefficient * pow(hoge - event.secondCoefficient, event.thirdCoefficient)
      if result.isNaN || result.isInfinite {
        throw CalculationError.invalidResult
      }
      return Int(result)
    }
  }

  /// それぞれの種目の数値を秒単位に変換する
  // ex. 1500m: 43050 -> 270.50
  // ex. 100m: 1055 -> 10.50
  private func convertScoreToDouble(score: Int) -> Double {
    let mSec = score % 100
    let sec = (score / 100) % 100
    let min = score / 10000
    return Double(min) * 60 + Double(sec) + (Double(mSec) / 100.0)
  }

  /// それぞれの種目の秒数を { 分秒ミリ秒 } に変換する
  private func convertScoreToInt(seconds: Double) -> Int {
    // 100m : 10.50
    // 1500m: 270.50
    let sec = floor(seconds)                // 100m: 10,   1500m: 270
    let mSec = floor((seconds - sec) * 100) // 100m: 50,   1500m: 50
    let min = floor(sec / 60)               // 100m: 0,    1500m: 4

    // 100m : 0     + 1000 + 50 = 1050
    // 1500m: 40000 + 3000 + 50 = 43050
    return Int((min * 10000) + ((sec - min * 60) * 100) + mSec)
  }

  enum CalculationError: Error {
    case invalidResult
    /// 最大ポイントを超過
    case overPoint
  }

  init(event: Event, score: String? = nil, point: Int? = nil) {
    self.event = event
    self.score = score
    self.point = point ?? 0
  }
}
