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

    @Test func 目安の記録は必要な得点以上になる() throws {
        let event = CombinedEvent.heptathlon
        let info = CombinedEventInfo(event: event, events: event.events)
        let plan = TargetPlan(info: info, target: 5600)
        let average = try #require(plan.averagePoint)
        #expect(average == 800)
        for requirement in plan.requirements {
            #expect(requirement.record != nil)
        }
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
