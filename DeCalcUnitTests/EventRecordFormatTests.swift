//
//  EventRecordFormatTests.swift
//  DeCalcUnitTests
//

import Testing
@testable import DeCalc

struct EventRecordFormatTests {

    @Test func 記録が単位つきの文字列に変換される() {
        #expect(Event.Run(.hundredM).formattedRecord("1050") == "10\"50")
        #expect(Event.Run(.thousandFiveHundredM).formattedRecord("43050") == "4'30\"50")
        #expect(Event.Jump(.longjump(.Men)).formattedRecord("650") == "6m50cm")
        #expect(Event.Throw(.shotput(.Men)).formattedRecord("1250") == "12m50cm")
    }
}
