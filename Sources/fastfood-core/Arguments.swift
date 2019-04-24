//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

struct Arguments {

    enum Command {
        case update, clean, help
    }

    var url: URL?
    var version: String?
    var command = Command.help
    var force = false
    var noCache = false
    var manualInput = false
    var unknownOptions: [String] = []

    //swiftlint:disable cyclomatic_complexity
    init?(arguments: [String]) {
        for (index, argument) in arguments.enumerated() {
            switch argument.lowercased() {
            case "update":
                command = .update
            case "clean":
                command = .clean
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
            case "--no-cache":
                noCache = true
            case "-mi", "--manual-input":
                manualInput = true
            default:
                if argument.starts(with: "-") {
                    unknownOptions.append(argument)
                }
            }
        }
    }
    //swiftlint:enable cyclomatic_complexity

    static let description: String = {
        return """
Usage: fastfood [options]
  update:
      Update fastlane in the project.
  clean:
      Clean all cached versions.
  help:
      Print this message.
  -u, --url:
      URL to a repo contains Fastfile.
  -v, --version:
      A tag or branch name.
  -f, --force:
      Update to last version.
  --no-cache:
      Update shared fastlane ignoring cached versions. Usually uses for fastlane in development stage.
  -mi, --manual-input:
      Enable manual input for configurating env file.
"""
    }()
}
