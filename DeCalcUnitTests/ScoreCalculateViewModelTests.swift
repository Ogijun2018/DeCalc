//
//  ScoreCalculateViewModelTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct ScoreCalculateViewModelTests {

    @Test func 記録の桁がそろうと得点が入り_数字を消すと得点も消える() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        // 100m 11"00 -> 861pt
        viewModel.recordDidChange(index: 0, record: "1100")
        #expect(viewModel.combinedEventInfo.events[0].point == 861)

        viewModel.recordDidChange(index: 0, record: "110")
        #expect(viewModel.combinedEventInfo.events[0].point == 0)
    }

    @Test func 手で編集した得点は記録を消しても残る() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.recordDidChange(index: 0, record: "1100")
        viewModel.pointDidEdit(index: 0, point: 900)

        viewModel.recordDidChange(index: 0, record: "110")
        #expect(viewModel.combinedEventInfo.events[0].point == 900)
    }

    @Test func 同じ得点の書き戻しは手入力として扱わない() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.recordDidChange(index: 0, record: "1100")
        viewModel.pointDidEdit(index: 0, point: 861)

        viewModel.recordDidChange(index: 0, record: "110")
        #expect(viewModel.combinedEventInfo.events[0].point == 0)
    }

    @Test func 得点から逆算すると記録が入り_得点はその記録の得点にそろう() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        // 100m 800pt -> 11"27（11"27 の実際の得点は 801pt）
        viewModel.pointDidEdit(index: 0, point: 800)
        viewModel.calculateButtonDidTap(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].score == "1127")
        #expect(viewModel.combinedEventInfo.events[0].point == 801)
        #expect(viewModel.combinedEventInfo.events[0].errorText == nil)
    }

    @Test func 最高得点を超える得点は逆算できずエラーになる() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.recordDidChange(index: 0, record: "1100")
        viewModel.pointDidEdit(index: 0, point: 9999)
        viewModel.calculateButtonDidTap(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].errorText != nil)
        #expect(viewModel.combinedEventInfo.events[0].score == "")
        // 入力した得点は消さない
        #expect(viewModel.combinedEventInfo.events[0].point == 9999)
    }

    @Test func 次の入力先は後ろの未入力を優先し_なければ先頭から探す() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .tetrathlon(.Men))
        // 4種目中、1つ目と3つ目が未入力
        viewModel.recordDidChange(index: 1, record: "1400")
        viewModel.recordDidChange(index: 3, record: "1200")
        #expect(viewModel.nextEmptyRecordIndex(after: 1) == 2)
        #expect(viewModel.nextEmptyRecordIndex(after: 3) == 0)

        viewModel.recordDidChange(index: 0, record: "5000")
        viewModel.recordDidChange(index: 2, record: "180")
        #expect(viewModel.nextEmptyRecordIndex(after: 2) == nil)
    }

    @Test func 分の単位がない種目は60秒を超えても秒のまま逆算される() throws {
        // 400m 300点 ≒ 63秒台。分に繰り上げると5桁になり、4桁の入力欄からあふれていた
        let viewModel = ScoreCalculateViewModel(combinedEvent: .tetrathlon(.Men))
        let index = try #require(viewModel.combinedEventInfo.events.firstIndex { $0.event == .Run(.fourHundredM) })
        viewModel.pointDidEdit(index: index, point: 300)
        viewModel.calculateButtonDidTap(index: index)
        let record = try #require(viewModel.combinedEventInfo.events[index].score)
        #expect(record.count == 4)
        #expect(record.hasPrefix("63"))
        #expect(viewModel.combinedEventInfo.events[index].point >= 300)
    }
}
