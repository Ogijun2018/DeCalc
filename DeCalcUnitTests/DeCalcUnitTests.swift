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
        let vm = CombinedModel(score: 999, event: .Run(.hundredM))
        #expect(vm.point == 1099)
    }

    @Test func 走種目のスコアが正常に計算される_4桁の場合() async throws {
        // 100m Men: 11"36 -> 782pt
        let vm = CombinedModel(score: 1136, event: .Run(.hundredM))
        #expect(vm.point == 782)
    }

    @Test func 走種目のスコアが正常に計算される_5桁の場合() async throws {
        // 1500m Men: 3'58"23 -> 966pt
        let vm = CombinedModel(score: 35823, event: .Run(.thousandFiveHundredM))
        #expect(vm.point == 966)
    }

    @Test func 走種目のスコアが正常に計算できなかったときは0を返す() async throws {
        // 1500m Men: 10'00"00 (0点)
        let vm = CombinedModel(score: 100000, event: .Run(.thousandFiveHundredM))
        #expect(vm.point == 0)
    }

    @Test func 跳躍種目のスコアが正常に計算される_3桁の場合() async throws {
        // LongJump Men: 6.50 -> 697pt
        var vm = CombinedModel(score: 650, event: .Jump(.longjump(.Men)))
        #expect(vm.point == 697)
        // LongJump Women: 6.50 -> 1007pt
        vm = CombinedModel(score: 650, event: .Jump(.longjump(.Women)))
        #expect(vm.point == 1007)
    }

    @Test func 跳躍種目のスコアが正常に計算できなかったときは0を返す() async throws {
        // LongJump Men: 1.00 -> 0pt
        var vm = CombinedModel(score: 100, event: .Jump(.longjump(.Men)))
        #expect(vm.point == 0)
        // LongJump Women: 1.00 -> 0pt
        vm = CombinedModel(score: 100, event: .Jump(.longjump(.Women)))
        #expect(vm.point == 0)
    }

    @Test func 投擲種目のスコアが正常に計算される_3桁の場合() async throws {
        // ShotPut Men: 9.50 -> 516pt
        var vm = CombinedModel(score: 950, event: .Throw(.shotput(.Men)))
        #expect(vm.point == 456)
        // ShotPut Women: 9.50 -> 562pt
        vm = CombinedModel(score: 950, event: .Throw(.shotput(.Women)))
        #expect(vm.point == 497)
    }

    @Test func 投擲種目のスコアが正常に計算される_4桁の場合() async throws {
        // JavelinThrow Men: 45.50 -> 522pt
        var vm = CombinedModel(score: 4550, event: .Throw(.javelinThrow(.Men)))
        #expect(vm.point == 522)
        // JavelinThrow Women: 45.50 -> 773pt
        vm = CombinedModel(score: 4550, event: .Throw(.javelinThrow(.Women)))
        #expect(vm.point == 773)
    }

    @Test func 投擲種目のスコアが正常に計算できなかった時は0を返す() async throws {
        // JavelinThrow Men: 3.00 -> 0pt
        var vm = CombinedModel(score: 300, event: .Throw(.javelinThrow(.Men)))
        #expect(vm.point == 0)
        // JavelinThrow Women: 3.00 -> 0pt
        vm = CombinedModel(score: 300, event: .Throw(.javelinThrow(.Women)))
        #expect(vm.point == 0)
    }

}
