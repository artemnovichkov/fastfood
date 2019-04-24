//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import XCTest
@testable import FastfoodCore

final class ArgumentsSpec: XCTestCase {

    // MARK: - Commands

    func testUpdateCommandParsing() {
        let arguments = Arguments(arguments: ["update"])
        XCTAssertEqual(arguments?.command, Arguments.Command.update)
    }

    func testCleanCommandParsing() {
        let arguments = Arguments(arguments: ["clean"])
        XCTAssertEqual(arguments?.command, Arguments.Command.clean)
    }

    func testHelpCommandParsing() {
        let arguments = Arguments(arguments: ["help"])
        XCTAssertEqual(arguments?.command, Arguments.Command.help)
    }

    // MARK: - Short options

    func testShortURLOptionParsing() {
        let urlString = "http://google.com"
        let arguments = Arguments(arguments: ["-u", urlString])
        XCTAssertEqual(arguments?.url, URL(string: urlString))
    }

    func testShortVersionOptionParsing() {
        let versionString = "1.0"
        let arguments = Arguments(arguments: ["-v", versionString])
        XCTAssertEqual(arguments?.version, versionString)
    }

    func testShortForceOptionParsing() {
        let arguments = Arguments(arguments: ["-f"])
        XCTAssertEqual(arguments?.force, true)
    }

    func testShortManualInputOptionParsing() {
        let arguments = Arguments(arguments: ["-mi"])
        XCTAssertEqual(arguments?.manualInput, true)
    }

    // MARK: - Long options

    func testLongURLOptionParsing() {
        let urlString = "http://google.com"
        let arguments = Arguments(arguments: ["--url", urlString])
        XCTAssertEqual(arguments?.url, URL(string: urlString))
    }

    func testLongVersionOptionParsing() {
        let versionString = "1.0"
        let arguments = Arguments(arguments: ["--version", versionString])
        XCTAssertEqual(arguments?.version, versionString)
    }

    func testLongForceOptionParsing() {
        let arguments = Arguments(arguments: ["--force"])
        XCTAssertEqual(arguments?.force, true)
    }

    func testLongCacheOptionParsing() {
        let arguments = Arguments(arguments: ["--no-cache"])
        XCTAssertEqual(arguments?.noCache, true)
    }

    func testLongManualInputOptionParsing() {
        let arguments = Arguments(arguments: ["--manual-input"])
        XCTAssertEqual(arguments?.manualInput, true)
    }

    // MARK: - Wrong formats

    func testWrongURLOption() {
        let arguments = Arguments(arguments: ["--url"])
        XCTAssertNil(arguments)
    }

    func testWrongVersionOption() {
        let arguments = Arguments(arguments: ["--version"])
        XCTAssertNil(arguments)
    }
}
