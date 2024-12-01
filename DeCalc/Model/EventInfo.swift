//
//  EventInfo.swift
//  DeCalc
//
//  Created by Jun Ogino on 2024/12/01.
//

import Foundation
/// 混成種目が持つ一種目の情報を持つstruct
struct EventInfo {
    /// 種目
    var event: Event
    /// 一種目の記録
    var score: Int?
    /// 一種目の点数
    var point: Int {
        guard let score = self.score else { return 0 }
        do {
            return try convertToScore(event: self.event, score: score)
        } catch CalculationError.invalidResult {
            return 0
        } catch {
            return 0
        }
    }

    /// 混成競技の得点計算方法
    /// ref: https://games.athleteranking.com/faq/faq07.php
    func convertToScore(event: Event, score: Int) throws -> Int {
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
        print("\(mSec), \(sec), \(min)")
        return Double(min) * 60 + Double(sec) + (Double(mSec) / 100.0)
    }

    enum CalculationError: Error {
        case invalidResult
    }
}
