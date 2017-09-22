//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {
    
    var url: URL?
    var tag: String?
    
    init(arguments: [String]) throws {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "-u", "--url":
                url = URL(string: arguments[index + 1])
            case "-t", "--tag":
                tag = arguments[index + 1]
            default: break
            }
        }
    }
    
    static let description: String = {
        return """
Usage: fastfood [options]
  -u, --url:
      URL to a repo contains Fastfile.
  -t, --tag:
      A version of Fastfile. Should be equals to any tag in Fastfile repo.
"""
    }()
}
