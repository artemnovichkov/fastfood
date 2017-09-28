//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import XCTest
@testable import FastfoodCore

final class TagSpec: XCTestCase {

    override func setUp() {

    }

    func testTagInitialization() {
        do {
            let hash = "1c6bd751e1f35688bc1bfcf95dadc8fb81c2daa1"
            let version = "1.0"
            let tag = try Tag(string: hash + "\trefs/tags/" + version)
            XCTAssertEqual(tag.hash, hash)
            XCTAssertEqual(tag.version, version)
        }
        catch {
            XCTFail("Should not throws")
        }
    }

    func testTagInitializationThrowing() {
        XCTAssertThrowsError(try Tag(string: "returns frong error")) { (error) in
            XCTAssertEqual(error as? Tag.Error, Tag.Error.wrongFormat)
        }
    }
}
