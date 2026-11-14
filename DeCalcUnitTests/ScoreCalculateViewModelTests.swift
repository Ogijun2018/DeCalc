//
//  ScoreCalculateViewModelTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct ScoreCalculateViewModelTests {

    @Test func 記録から計算した得点は記録を消すと消える() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.combinedEventInfo.events[0].score = "1100"
        viewModel.scoreFilled(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point > 0)

        viewModel.combinedEventInfo.events[0].score = "110"
        viewModel.recordBecameIncomplete(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point == 0)
    }

    @Test func 手で編集した得点は記録を消しても残る() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .decathlon)
        viewModel.combinedEventInfo.events[0].score = "1100"
        viewModel.scoreFilled(index: 0)
        viewModel.pointDidEdit(index: 0, point: 900)

        viewModel.combinedEventInfo.events[0].score = "110"
        viewModel.recordBecameIncomplete(index: 0)
        #expect(viewModel.combinedEventInfo.events[0].point == 900)
    }

    @Test func 次の入力先は後ろの未入力を優先し_なければ先頭から探す() {
        let viewModel = ScoreCalculateViewModel(combinedEvent: .tetrathlon(.Men))
        // 4種目中、1つ目と3つ目が未入力
        viewModel.combinedEventInfo.events[1].score = "1400"
        viewModel.combinedEventInfo.events[3].score = "1200"
        #expect(viewModel.nextEmptyRecordIndex(after: 1) == 2)
        #expect(viewModel.nextEmptyRecordIndex(after: 3) == 0)

        viewModel.combinedEventInfo.events[0].score = "5000"
        viewModel.combinedEventInfo.events[2].score = "180"
        #expect(viewModel.nextEmptyRecordIndex(after: 2) == nil)
    }
}
