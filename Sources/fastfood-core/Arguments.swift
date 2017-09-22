//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {
    
    var url: String?
    var tag: String?
    
    init(arguments: [String]) throws {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "--url", "-u":
                url = arguments[index + 1]
            case "--tag", "-t":
                tag = arguments[index + 1]
            default: break
            }
        }
    }
}
