import XCTest
@testable import SwiftSpeech

final class SwiftSpeechTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SwiftSpeech().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
