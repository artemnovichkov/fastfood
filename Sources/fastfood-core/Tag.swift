//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

/// Struct for tag reference.
struct Tag {

    enum Error: Swift.Error {
        case wrongFormat
    }

    let hash: String
    let version: String

    init(string: String) throws {
        let components = string.components(separatedBy: "\t")
        guard components.count == 2 else {
            throw Error.wrongFormat
        }
        hash = components[0]
        guard let version = components[1].components(separatedBy: "/").last else {
            throw Error.wrongFormat
        }
        self.version = version
    }
}
