import XCTest
import class Foundation.Bundle

final class chapter01Tests: XCTestCase {
    func testFilteredAndLowercasedSubscriptions() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        // Mac Catalyst won't have `Process`, but it is supported for executables.
        #if !targetEnvironment(macCatalyst)

        let fooBinary = productsDirectory.appendingPathComponent("chapter01")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(process.terminationStatus, 0)
        let lines = try XCTUnwrap(output).split(separator: "\n").map(String.init)
        XCTAssertEqual(lines, [
            "onNext:  Rx", "onNext:  RxS", "onNext:  RxSw",
            "onNext:  RxSwi", "onNext:  RxSwif", "onNext:  RxSwift",
            "onNext:  rx", "onNext:  rxs", "onNext:  rxsw",
            "onNext:  rxswi", "onNext:  rxswif", "onNext:  rxswift",
        ])
        #endif
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
}
