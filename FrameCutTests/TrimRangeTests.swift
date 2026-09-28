import Testing
@testable import FrameCut

@Suite("Precision trim range")
struct TrimRangeTests {
    @Test("A range is clamped to its media duration")
    func clampsToDuration() {
        let range = TrimRange(start: -4, end: 90, duration: 60)

        #expect(range.start == 0)
        #expect(range.end == 60)
        #expect(range.length == 60)
    }

    @Test("The start handle cannot cross the minimum clip length")
    func protectsMinimumLengthWhenMovingStart() {
        let range = TrimRange(start: 10, end: 20, duration: 60, minimumLength: 1)

        let updated = range.movingStart(to: 24)

        #expect(updated.start == 19)
        #expect(updated.end == 20)
    }

    @Test("The end handle cannot cross the minimum clip length")
    func protectsMinimumLengthWhenMovingEnd() {
        let range = TrimRange(start: 10, end: 20, duration: 60, minimumLength: 1)

        let updated = range.movingEnd(to: 4)

        #expect(updated.start == 10)
        #expect(updated.end == 11)
    }

    @Test("A zero-duration item produces an empty safe range")
    func handlesZeroDuration() {
        let range = TrimRange.full(duration: 0)

        #expect(range.start == 0)
        #expect(range.end == 0)
        #expect(range.progressBounds == 0...0)
    }
}
