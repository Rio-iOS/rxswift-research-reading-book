import Foundation
import XCTest
import RxSwift
@testable import chapter06

final class LatestValuesTests: XCTestCase {
    func testNewInputCancelsOlderDelayedValue() {
        let clock = HistoricalScheduler(initialClock: Date(timeIntervalSince1970: 0))
        let input = PublishSubject<Int>()
        var output: [Int] = []
        let subscription = Chapter06.latestValues(input, delay: .seconds(1), scheduler: clock).subscribe(onNext: { output.append($0) })
        input.onNext(1)
        clock.advanceTo(Date(timeIntervalSince1970: 0.5))
        input.onNext(2)
        clock.advanceTo(Date(timeIntervalSince1970: 1))
        XCTAssertTrue(output.isEmpty)
        clock.advanceTo(Date(timeIntervalSince1970: 1.5))
        XCTAssertEqual(output, [2])
        input.onNext(3)
        subscription.dispose()
        XCTAssertFalse(input.hasObservers)
        clock.advanceTo(Date(timeIntervalSince1970: 3))
        XCTAssertEqual(output, [2])
    }

    func testSourceErrorTerminatesAndCancelsDelayedOutput() {
        let clock = HistoricalScheduler(initialClock: Date(timeIntervalSince1970: 0))
        let input = PublishSubject<Int>()
        var failed = false
        let subscription = Chapter06.latestValues(input, delay: .seconds(1), scheduler: clock).subscribe(onNext: { _ in XCTFail("Pending value must be cancelled") }, onError: { _ in failed = true })
        input.onNext(1)
        input.onError(URLError(.timedOut))
        clock.start()
        XCTAssertTrue(failed)
        XCTAssertFalse(input.hasObservers)
        subscription.dispose()
    }
}
