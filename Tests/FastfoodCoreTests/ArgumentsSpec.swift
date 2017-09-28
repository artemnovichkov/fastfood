//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import XCTest
@testable import FastfoodCore

final class ArgumentsSpec: XCTestCase {
    
    override func setUp() {
        
    }
    
    func testUpdateCommandParsing() {
        let arguments = Arguments(arguments: ["update"])
        XCTAssertEqual(arguments?.command, Arguments.Command.update)
    }
    
    func testHelpCommandParsing() {
        let arguments = Arguments(arguments: ["help"])
        XCTAssertEqual(arguments?.command, Arguments.Command.help)
    }
    
    func testURLOptionParsing() {
        let urlString = "http://google.com"
        let arguments = Arguments(arguments: ["-u", urlString])
        XCTAssertEqual(arguments?.url, URL(string: urlString))
    }
    
    func testTagOptionParsing() {
        let tagString = "1.0"
        let arguments = Arguments(arguments: ["-t", tagString])
        XCTAssertEqual(arguments?.tag, tagString)
    }
    
    func testBranchOptionParsing() {
        let branchString = "develop"
        let arguments = Arguments(arguments: ["-b", branchString])
        XCTAssertEqual(arguments?.branch, branchString)
    }
}
