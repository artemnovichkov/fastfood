//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class Fastfood {

    private enum Keys {
        static let url = "https://github.com/rosberry/RSBFastlane"
        static let environmentTags: [String: String] = ["bundle_name": "bundle name",
                                                       "project_name": "project name"]
    }

    enum Error: Swift.Error {
        case wrongURL
    }

    private var arguments: [String]
    private let fastfileService: FastfileService
    private let consoleIO: ConsoleIO = .init()

    public init(arguments: [String] = Array(CommandLine.arguments.dropFirst()),
                fastfileService: FastfileService = .init()) {
        self.arguments = arguments
        self.fastfileService = fastfileService
    }

    public func run() throws {
        guard let arguments = Arguments(arguments: self.arguments) else {
            print("❌ Wrong arguments")
            print(Arguments.description)
            return
        }

        if !arguments.unknownOptions.isEmpty {
            let description = arguments.unknownOptions.reduce("⁉️ Unknown options:") { description, option in
                return description + "\n" + option
            }
            print(description)
        }

        switch arguments.command {
        case .help:
            print(Arguments.description)
        case .update:
            try update(with: arguments)
        case .clean:
            fastfileService.clean()
        }
    }

    // MARK: - Private

    private func update(with arguments: Arguments) throws {
        let argumentURL = arguments.url ?? URL(string: Keys.url)
        guard let url = argumentURL else {
            print(Arguments.description)
            throw Error.wrongURL
        }

        var version: String? = nil
        if !arguments.force {
            if let argumentVersion = arguments.version {
                version = argumentVersion
            }
            else {
                version = fastfileService.version()
            }
        }

        let checkCache = !arguments.noCache
        let path = try fastfileService.updateSharedFastlaneIfNeeded(fromRemotePath: url.absoluteString,
                                                                    version: version,
                                                                    checkCache: checkCache)
        print("🤖 Updating...")
        try fastfileService.updateProjectFastlaneIfNeeded(withPath: path + "fastlane")
        if arguments.manualInput {
            try startManualInputPhase()
        }
        print("🎉 Done!")
    }

    private func startManualInputPhase() throws {
        var valuesToUpdate = [String: String]()
        Keys.environmentTags.forEach { key, value in
            print("Enter your \(value)")
            guard let textFromConsole = consoleIO.getInput() else {
                return
            }
            valuesToUpdate[key] = textFromConsole
        }
        try fastfileService.updateEnvFile(values: valuesToUpdate)
    }
}

extension Fastfood.Error: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .wrongURL: return "Wrong URL. Use --url parameter."
        }
    }
}
