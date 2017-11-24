//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class Fastfood {

    private enum Keys {
        static let url = "https://github.com/rosberry/RSBFastlane"
    }

    enum Error: Swift.Error {
        case wrongURL
    }

    private var arguments: [String]
    private let fastfileService: FastfileService

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
        }
    }

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
        print("🎉 Done!")
    }
}

extension Fastfood.Error: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .wrongURL: return "Wrong URL. Use --url parameter."
        }
    }
}
