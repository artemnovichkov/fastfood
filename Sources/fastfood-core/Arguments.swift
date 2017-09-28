//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case update, help
    }

    var url: URL?
    var tag: String?
    var branch: String?
    var path: String?
    var command = Command.help
    var force = false

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
            case "-t", "--tag":
                let tagIndex = index + 1
                guard arguments.count > tagIndex else {
                    return nil
                }
                tag = arguments[tagIndex]
            case "-b", "--branch":
                let branchIndex = index + 1
                guard arguments.count > branchIndex else {
                    return nil
                }
                branch = arguments[branchIndex]
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

    static let description: String = {
        return """
Usage: fastfood update [options]
  -u, --url:
      URL to a repo contains Fastfile.
  -t, --tag:
      A version of Fastfile. Should be equals to any tag in Fastfile repo.
  -b, --branch:
      A branch of a repo contains Fastfile.
  -f, --force:
      Update to last version.
  -p, --path:
      A path to Fastfile. `fastlane/Fastfile` by default.
"""
    }()
}
