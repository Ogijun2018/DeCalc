//
//  DeCalcUnitTests.swift
//  DeCalcUnitTests
//
//  Created by Jun Ogino on 2024/10/27.
//

import Testing
@testable import DeCalc

struct DeCalcUnitTests {

    @Test func 走種目のスコアが正常に計算される_3桁の場合() async throws {
        // 100m Men: 9"99 -> 1099pt
        let info = EventInfo(event: .Run(.hundredM), score: "999")
        #expect(info.point == 1099)
    }

    @Test func 走種目のスコアが正常に計算される_4桁の場合() async throws {
        // 100m Men: 11"36 -> 782pt
        let info = EventInfo(event: .Run(.hundredM), score: "1136")
        #expect(info.point == 782)
    }

    @Test func 走種目のスコアが正常に計算される_5桁の場合() async throws {
        // 1500m Men: 3'58"23 -> 966pt
        let info = EventInfo(event: .Run(.thousandFiveHundredM), score: "35823")
        #expect(info.point == 966)
    }

    @Test func 走種目のスコアが正常に計算できなかったときは0を返す() async throws {
        // 1500m Men: 10'00"00 (0点)
        let info = EventInfo(event: .Run(.thousandFiveHundredM), score: "100000")
        #expect(info.point == 0)
    }

    @Test func 跳躍種目のスコアが正常に計算される_3桁の場合() async throws {
        // LongJump Men: 6.50 -> 697pt
        var info = EventInfo(event: .Jump(.longjump(.Men)), score: "650")
        #expect(info.point == 697)
        // LongJump Women: 6.50 -> 1007pt
        info = EventInfo(event: .Jump(.longjump(.Women)), score: "650")
        #expect(info.point == 1007)
    }

    @Test func 跳躍種目のスコアが正常に計算できなかったときは0を返す() async throws {
        // LongJump Men: 1.00 -> 0pt
        var info = EventInfo(event: .Jump(.longjump(.Men)), score: "100")
        #expect(info.point == 0)
        // LongJump Women: 1.00 -> 0pt
        info = EventInfo(event: .Jump(.longjump(.Women)), score: "100")
        #expect(info.point == 0)
    }

    @Test func 投擲種目のスコアが正常に計算される_3桁の場合() async throws {
        // ShotPut Men: 9.50 -> 516pt
        var info = EventInfo(event: .Throw(.shotput(.Men)), score: "950")
        #expect(info.point == 456)
        // ShotPut Women: 9.50 -> 562pt
        info = EventInfo(event: .Throw(.shotput(.Women)), score: "950")
        #expect(info.point == 497)
    }

    @Test func 投擲種目のスコアが正常に計算される_4桁の場合() async throws {
        // JavelinThrow Men: 45.50 -> 522pt
        var info = EventInfo(event: .Throw(.javelinThrow(.Men)), score: "4550")
        #expect(info.point == 522)
        // JavelinThrow Women: 45.50 -> 773pt
        info = EventInfo(event: .Throw(.javelinThrow(.Women)), score: "4550")
        #expect(info.point == 773)
    }

    @Test func 投擲種目のスコアが正常に計算できなかった時は0を返す() async throws {
        // JavelinThrow Men: 3.00 -> 0pt
        var info = EventInfo(event: .Throw(.javelinThrow(.Men)), score: "300")
        #expect(info.point == 0)
        // JavelinThrow Women: 3.00 -> 0pt
        info = EventInfo(event: .Throw(.javelinThrow(.Women)), score: "300")
        #expect(info.point == 0)
    }

    @Test func 走種目のポイントが正常に計算される_100m() async throws {
        // 100m Men: 800pt -> 11"27
        let info = EventInfo(event: .Run(.hundredM), point: 800)
        #expect(info.score == "1127")
    }

    @Test func 走種目のポイントが正常に計算される_1500m() async throws {
        // 1500m Men: 966pt -> 3'58"35
        // ポイント→記録の計算結果と記録→ポイントの計算結果は異なることがあるがこれは正常
        let info = EventInfo(event: .Run(.thousandFiveHundredM), point: 966)
        #expect(info.score == "35835")
    }

    @Test func 跳躍種目のポイントが正常に計算される() async throws {
        // LongJump Men: 697pt -> 6.50
        let info = EventInfo(event: .Jump(.longjump(.Men)), point: 697)
        #expect(info.score == "650")
    }

    @Test func 投擲種目のポイントが正常に計算される() async throws {
        // JavelinThrow Men: 522pt -> 45.50
        let info = EventInfo(event: .Throw(.javelinThrow(.Men)), point: 522)
        #expect(info.score == "4545")
    }

}
