//
//  IdentityTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

struct IdentityTests {

    /// SwiftUIのForEachが使うのと同じ、Identifiableとしての識別子
    private func identity<T: Identifiable>(_ value: T) -> T.ID { value.id }

    @Test func 種目の識別子は記録や得点が変わっても変わらない() {
        // 識別子が内容ごと変わると、1文字入力するたびに入力欄が作り直されてフォーカスが外れる
        var event = EventInfo(event: .Run(.hundredM))
        let before = identity(event)
        event.score = "1"
        event.point = 800
        #expect(identity(event) == before)
    }

    @Test func 遷移先は値そのものが識別子になる() {
        #expect(identity(Router.Help(.decathlon)) == Router.Help(.decathlon))
        #expect(identity(Router.Help(.decathlon)) != identity(Router.Help(.heptathlon)))
    }
}
