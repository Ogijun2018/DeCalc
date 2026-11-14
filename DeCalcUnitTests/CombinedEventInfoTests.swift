//
//  CombinedEventInfoTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct CombinedEventInfoTests {

    @Test func 十種競技は1日目と2日目に5種目ずつ分かれる() {
        let info = CombinedEventInfo(event: .decathlon, events: CombinedEvent.decathlon.events)
        let sections = info.daySections
        #expect(sections.map(\.day) == [1, 2])
        #expect(sections.map(\.events.count) == [5, 5])
    }

    @Test func 七種競技は1日目4種目と2日目3種目に分かれる() {
        let info = CombinedEventInfo(event: .heptathlon, events: CombinedEvent.heptathlon.events)
        #expect(info.daySections.map(\.events.count) == [4, 3])
    }

    @Test func 四種競技は日で分かれない() {
        let event = CombinedEvent.tetrathlon(.Men)
        let info = CombinedEventInfo(event: event, events: event.events)
        #expect(info.daySections.count == 1)
        #expect(info.daySections.first?.day == nil)
    }

    @Test func 日ごとの小計と入力済み種目数が計算される() {
        var events = CombinedEvent.decathlon.events
        events[0].point = 800
        events[1].point = 700
        events[5].point = 900
        let info = CombinedEventInfo(event: .decathlon, events: events)
        #expect(info.daySections.map(\.events.totalPoint) == [1500, 900])
        #expect(info.daySections.map(\.events.enteredCount) == [2, 1])
        #expect(info.events.enteredCount == 3)
        #expect(info.point == 2400)
    }

    @Test func セクションを見分ける値は記録を入力しても変わらない() {
        // 画面はdayでセクションを見分ける。入力のたびに変わると入力欄が作り直されてしまう
        var info = CombinedEventInfo(event: .decathlon, events: CombinedEvent.decathlon.events)
        let before = info.daySections.map(\.day)
        info.events[0].score = "1"
        info.events[7].point = 800
        #expect(info.daySections.map(\.day) == before)
        #expect(Set(before).count == before.count)
    }

    @Test func セクション内の種目は全種目の配列での位置を保つ() {
        // 画面は、この位置を使って種目カードとViewModelを結びつける
        let info = CombinedEventInfo(event: .decathlon, events: CombinedEvent.decathlon.events)
        #expect(info.daySections.map(\.events.indices) == [0..<5, 5..<10])
    }
}
