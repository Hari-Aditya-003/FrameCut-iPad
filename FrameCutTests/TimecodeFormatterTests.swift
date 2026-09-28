import Testing
@testable import FrameCut

@Suite("Timecode formatting")
struct TimecodeFormatterTests {
    @Test("Short media uses minute and second fields")
    func shortTimecode() {
        #expect(TimecodeFormatter.string(seconds: 65.2) == "01:05")
    }

    @Test("Long media includes hours")
    func longTimecode() {
        #expect(TimecodeFormatter.string(seconds: 3_723) == "1:02:03")
    }

    @Test("Invalid and negative values are safe")
    func safeValues() {
        #expect(TimecodeFormatter.string(seconds: -8) == "00:00")
        #expect(TimecodeFormatter.string(seconds: .infinity) == "00:00")
    }

    @Test("Precise timecodes carry rounded seconds into the next minute")
    func preciseTimecodeRollover() {
        #expect(TimecodeFormatter.preciseString(seconds: 59.96) == "01:00.0")
    }
}
