//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import XCTest
@testable import FastfoodCore

final class ArgumentsSpec: XCTestCase {

    override func setUp() {

    }

    // MARK: - Commands

    func testUpdateCommandParsing() {
        let arguments = Arguments(arguments: ["update"])
        XCTAssertEqual(arguments?.command, Arguments.Command.update)
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
