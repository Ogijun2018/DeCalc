//
//  TargetPlanTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

struct TargetPlanTests {

    @Test func 記録が単位つきの文字列に変換される() {
        #expect(Event.Run(.hundredM).formattedRecord("1050") == "10\"50")
        #expect(Event.Run(.thousandFiveHundredM).formattedRecord("43050") == "4'30\"50")
        #expect(Event.Jump(.longjump(.Men)).formattedRecord("650") == "6m50cm")
        #expect(Event.Throw(.shotput(.Men)).formattedRecord("1250") == "12m50cm")
    }

    @Test func 未入力の種目に残り得点が均等に割り振られる() {
        var events = CombinedEvent.decathlon.events
        events[0].point = 800
        events[1].point = 700
        let info = CombinedEventInfo(event: .decathlon, events: events)
        let plan = TargetPlan(info: info, target: 7000)
        #expect(plan.currentPoint == 1500)
        #expect(plan.remainingPoint == 5500)
        // 5500 / 8 = 687.5 → 切り上げ
        #expect(plan.averagePoint == 688)
        #expect(plan.requirements.count == 8)
        #expect(plan.isAchieved == false)
    }

    @Test(arguments: [
        (CombinedEvent.decathlon, 3000), (.decathlon, 7000), (.decathlon, 9000),
        (.heptathlon, 3000), (.heptathlon, 5600), (.heptathlon, 7000),
        (.octathlon, 5000), (.tetrathlon(.Men), 2500), (.tetrathlon(.Women), 2500),
    ])
    func 目安の記録で必要な得点以上が取れる(event: CombinedEvent, target: Int) throws {
        let plan = TargetPlan(info: .init(event: event, events: event.events), target: target)
        for requirement in plan.requirements {
            guard let digits = requirement.recordDigits else { continue }
            let score = try #require(Int(digits))
            let point = try EventInfo(event: requirement.event).convertToPoint(score: score)
            #expect(point >= requirement.point, "\(requirement.name): \(digits) -> \(point)")
        }
    }

    @Test func 最高得点を超える場合は理由がわかる() {
        // 1種目あたり5000点 → どの種目も最高得点を超える
        let tetrathlon = CombinedEvent.tetrathlon(.Men)
        let plan = TargetPlan(info: .init(event: tetrathlon, events: tetrathlon.events), target: 20000)
        #expect(plan.requirements.count == 4)
        #expect(plan.requirements.allSatisfy { $0.recordDigits == nil && $0.unavailable == .aboveMaximum })
    }

    @Test func 目標を超えている場合は達成済みになる() {
        var events = CombinedEvent.tetrathlon(.Men).events
        for index in events.indices { events[index].point = 600 }
        let info = CombinedEventInfo(event: .tetrathlon(.Men), events: events)
        let plan = TargetPlan(info: info, target: 2000)
        #expect(plan.isAchieved)
        #expect(plan.remainingPoint == 0)
        #expect(plan.averagePoint == nil)
        #expect(plan.requirements.isEmpty)
    }

    @Test func 目標合計点が競技ごとに保存される() throws {
        let suiteName = "TargetPlanTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let store = TargetScoreStore(defaults: defaults)

        #expect(store.target(for: .decathlon) == nil)
        store.setTarget(7000, for: .decathlon)
        #expect(store.target(for: .decathlon) == 7000)
        #expect(store.target(for: .heptathlon) == nil)
        store.setTarget(nil, for: .decathlon)
        #expect(store.target(for: .decathlon) == nil)
    }
}
