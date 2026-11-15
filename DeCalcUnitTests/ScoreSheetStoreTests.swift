//
//  ScoreSheetStoreTests.swift
//  DeCalcUnitTests
//

import Foundation
import Testing
@testable import DeCalc

struct ScoreSheetStoreTests {

    /// テストごとに独立したUserDefaultsを使うストアを作る
    private func makeStore() throws -> (store: ScoreSheetStore, cleanUp: () -> Void) {
        let suiteName = "ScoreSheetStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        return (ScoreSheetStore(defaults: defaults), { defaults.removePersistentDomain(forName: suiteName) })
    }

    private func makeInfo(_ event: CombinedEvent, points: [Int]) -> CombinedEventInfo {
        var events = event.events
        for (index, point) in points.enumerated() {
            events[index].point = point
        }
        return CombinedEventInfo(event: event, events: events)
    }

    @Test func 保存した記録が競技ごとに新しい順で取得できる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        let older = SavedScoreSheet(
            info: makeInfo(.decathlon, points: [800, 700]),
            name: "Spring",
            date: Date(timeIntervalSince1970: 1_000)
        )
        let newer = SavedScoreSheet(
            info: makeInfo(.decathlon, points: [600]),
            name: "",
            date: Date(timeIntervalSince1970: 2_000)
        )
        store.save(older)
        store.save(newer)
        store.save(SavedScoreSheet(info: makeInfo(.heptathlon, points: [900]), name: ""))

        let sheets = store.sheets(for: .decathlon)
        #expect(sheets.map(\.id) == [newer.id, older.id])
        #expect(sheets.map(\.total) == [600, 1500])
        #expect(store.sheets(for: .heptathlon).count == 1)
    }

    @Test func PBとして保存した記録のうち合計点が最も高いものが自己ベストになる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        #expect(store.sheets(for: .decathlon).personalBest == nil)
        let best = SavedScoreSheet(info: makeInfo(.decathlon, points: [900, 900]), name: "", isPersonalBest: true)
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [800]), name: "", isPersonalBest: true))
        store.save(best)
        // PBとして保存していない記録は、合計点が高くても自己ベストにならない
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [1000, 1000]), name: "", isTarget: true))
        #expect(store.sheets(for: .decathlon).personalBest?.id == best.id)
    }

    @Test func 目標点として保存した記録のうち最も新しいものが目標になる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        #expect(store.sheets(for: .decathlon).target == nil)
        let newer = SavedScoreSheet(
            info: makeInfo(.decathlon, points: [850]),
            name: "",
            isTarget: true,
            date: Date(timeIntervalSince1970: 2_000)
        )
        store.save(newer)
        store.save(SavedScoreSheet(
            info: makeInfo(.decathlon, points: [900]),
            name: "",
            isTarget: true,
            date: Date(timeIntervalSince1970: 1_000)
        ))
        // 目標点として保存していない記録は、新しくても目標にならない
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [700]), name: "", isPersonalBest: true))
        #expect(store.sheets(for: .decathlon).target?.id == newer.id)

        // 目標の記録を削除すると、その前に保存した目標に戻る
        store.delete(id: newer.id)
        #expect(store.sheets(for: .decathlon).target?.total == 900)
    }

    @Test func 印がなかった頃に保存した記録は自己ベストの比較に使われる() throws {
        let json = """
        [{"id":"00000000-0000-0000-0000-000000000001","date":0,"name":"Old","eventKey":"decathlon",
          "entries":[{"record":"1100","point":861}]}]
        """
        let sheets = try JSONDecoder().decode([SavedScoreSheet].self, from: Data(json.utf8))
        #expect(sheets.personalBest?.total == 861)
        #expect(sheets.target == nil)
    }

    @Test func 種目ごとの自己ベストは保存した記録の中の最高点になる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        #expect(store.sheets(for: .decathlon).bestEventPoints(eventCount: 10) == Array(repeating: 0, count: 10))
        // 合計点の自己ベストは1つ目だが、2種目目の最高点は2つ目の記録
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [900, 600, 800]), name: "", isPersonalBest: true))
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [700, 750]), name: "", isPersonalBest: true))
        // PBとして保存していない記録の得点は含めない
        store.save(SavedScoreSheet(info: makeInfo(.decathlon, points: [950, 950, 950, 950]), name: "", isTarget: true))
        let best = store.sheets(for: .decathlon).bestEventPoints(eventCount: 10)
        #expect(Array(best.prefix(4)) == [900, 750, 800, 0])
    }

    @Test func 記録を削除できる() throws {
        let (store, cleanUp) = try makeStore()
        defer { cleanUp() }
        let sheet = SavedScoreSheet(info: makeInfo(.octathlon, points: [500]), name: "")
        store.save(sheet)
        store.delete(id: sheet.id)
        #expect(store.sheets(for: .octathlon).isEmpty)
    }

    @Test func 桁が埋まっている記録だけが保存される() {
        var events = CombinedEvent.decathlon.events
        events[0].score = "1100"
        events[0].point = 861
        events[1].score = "65"
        let sheet = SavedScoreSheet(
            info: CombinedEventInfo(event: .decathlon, events: events),
            name: "  Trials  "
        )
        #expect(sheet.name == "Trials")
        #expect(sheet.entries[0].record == "1100")
        #expect(sheet.entries[1].record == nil)
        #expect(sheet.total == 861)
    }
}
