//
//  DeCalcUnitTests.swift
//  DeCalcUnitTests
//
//  Created by Jun Ogino on 2024/10/27.
//

import Testing
@testable import DeCalc

/// 記録⇄得点の計算（EventInfo.convertToPoint / convertToScore）のテスト
/// EventInfoのイニシャライザは得点を計算しないため、変換メソッドを直接呼び出して確認する
struct DeCalcUnitTests {

    @Test func 走種目のスコアが正常に計算される_3桁の場合() async throws {
        // 100m Men: 9"99 -> 1099pt
        let info = EventInfo(event: .Run(.hundredM))
        #expect(try info.convertToPoint(score: 999) == 1099)
    }

    @Test func 走種目のスコアが正常に計算される_4桁の場合() async throws {
        // 100m Men: 11"36 -> 782pt
        let info = EventInfo(event: .Run(.hundredM))
        #expect(try info.convertToPoint(score: 1136) == 782)
    }

    @Test func 走種目のスコアが正常に計算される_5桁の場合() async throws {
        // 1500m Men: 3'58"23 -> 966pt
        let info = EventInfo(event: .Run(.thousandFiveHundredM))
        #expect(try info.convertToPoint(score: 35823) == 966)
    }

    @Test func 走種目のスコアが計算できない記録はエラーになる() async throws {
        // 1500m Men: 10'00"00 は基準タイム(8'00"00)より遅く計算できない
        let info = EventInfo(event: .Run(.thousandFiveHundredM))
        #expect(throws: EventInfo.CalculationError.invalidResult) {
            try info.convertToPoint(score: 100000)
        }
    }

    @Test func 跳躍種目のスコアが正常に計算される_3桁の場合() async throws {
        // LongJump Men: 6.50 -> 697pt
        #expect(try EventInfo(event: .Jump(.longjump(.Men))).convertToPoint(score: 650) == 697)
        // LongJump Women: 6.50 -> 1007pt
        #expect(try EventInfo(event: .Jump(.longjump(.Women))).convertToPoint(score: 650) == 1007)
    }

    @Test func 跳躍種目のスコアが計算できない記録はエラーになる() async throws {
        // LongJump: 1.00 は基準記録より低く計算できない
        #expect(throws: EventInfo.CalculationError.invalidResult) {
            try EventInfo(event: .Jump(.longjump(.Men))).convertToPoint(score: 100)
        }
        #expect(throws: EventInfo.CalculationError.invalidResult) {
            try EventInfo(event: .Jump(.longjump(.Women))).convertToPoint(score: 100)
        }
    }

    @Test func 投擲種目のスコアが正常に計算される_3桁の場合() async throws {
        // ShotPut Men: 9.50 -> 456pt
        #expect(try EventInfo(event: .Throw(.shotput(.Men))).convertToPoint(score: 950) == 456)
        // ShotPut Women: 9.50 -> 497pt
        #expect(try EventInfo(event: .Throw(.shotput(.Women))).convertToPoint(score: 950) == 497)
    }

    @Test func 投擲種目のスコアが正常に計算される_4桁の場合() async throws {
        // JavelinThrow Men: 45.50 -> 522pt
        #expect(try EventInfo(event: .Throw(.javelinThrow(.Men))).convertToPoint(score: 4550) == 522)
        // JavelinThrow Women: 45.50 -> 773pt
        #expect(try EventInfo(event: .Throw(.javelinThrow(.Women))).convertToPoint(score: 4550) == 773)
    }

    @Test func 投擲種目のスコアが計算できない記録はエラーになる() async throws {
        // JavelinThrow: 3.00 は基準記録より短く計算できない
        #expect(throws: EventInfo.CalculationError.invalidResult) {
            try EventInfo(event: .Throw(.javelinThrow(.Men))).convertToPoint(score: 300)
        }
        #expect(throws: EventInfo.CalculationError.invalidResult) {
            try EventInfo(event: .Throw(.javelinThrow(.Women))).convertToPoint(score: 300)
        }
    }

    @Test func 計算できない記録を入力すると得点は0になる() async throws {
        // 画面上はエラーにせず0点として扱う（ScoreCalculateViewModel.scoreFilled）
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        let index = try #require(
            viewModel.combinedEventInfo.events.firstIndex { $0.event == .Run(.thousandFiveHundredM) }
        )
        viewModel.combinedEventInfo.events[index].point = 500
        viewModel.combinedEventInfo.events[index].score = "100000"
        viewModel.scoreFilled(index: index)
        #expect(viewModel.combinedEventInfo.events[index].point == 0)
    }

    @Test func 走種目のポイントが正常に計算される_100m() async throws {
        // 100m Men: 800pt -> 11"27
        let info = EventInfo(event: .Run(.hundredM))
        #expect(try info.convertToScore(point: 800) == 1127)
    }

    @Test func 走種目のポイントが正常に計算される_1500m() async throws {
        // 1500m Men: 966pt -> 3'58"35
        // ポイント→記録の計算結果と記録→ポイントの計算結果は異なることがあるがこれは正常
        let info = EventInfo(event: .Run(.thousandFiveHundredM))
        #expect(try info.convertToScore(point: 966) == 35835)
    }

    @Test func 跳躍種目のポイントが正常に計算される() async throws {
        // LongJump Men: 697pt -> 6.50
        let info = EventInfo(event: .Jump(.longjump(.Men)))
        #expect(try info.convertToScore(point: 697) == 650)
    }

    @Test func 投擲種目のポイントが正常に計算される() async throws {
        // JavelinThrow Men: 522pt -> 45.45
        let info = EventInfo(event: .Throw(.javelinThrow(.Men)))
        #expect(try info.convertToScore(point: 522) == 4545)
    }

}
