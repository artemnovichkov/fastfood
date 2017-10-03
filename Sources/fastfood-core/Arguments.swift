//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case update, help
    }

    var url: URL?
    var version: String?
    var path: String?
    var command = Command.help
    var force = false

    //swiftlint:disable cyclomatic_complexity
    init?(arguments: [String]) {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "update":
                command = .update
            case "help":
                command = .help
            case "-u", "--url":
                let urlIndex = index + 1
                guard arguments.count > urlIndex else {
                    return nil
                }
                url = URL(string: arguments[urlIndex])
            case "-v", "--version":
                let versionIndex = index + 1
                guard arguments.count > versionIndex else {
                    return nil
                }
                version = arguments[versionIndex]
            case "-f", "--force":
                force = true
            case "-p", "--path":
                let pathIndex = index + 1
                guard arguments.count > pathIndex else {
                    return nil
                }
                path = arguments[pathIndex]
            default: break
            }
        }
    }
    //swiftlint:enable cyclomatic_complexity

    static let description: String = {
        return """
Usage: fastfood update [options]
  -u, --url:
      URL to a repo contains Fastfile.
  -v, --version:
      A tag or branch name.
  -f, --force:
      Update to last version.
  -p, --path:
      A path to Fastfile. `fastlane/Fastfile` by default.
"""
    }()
}
