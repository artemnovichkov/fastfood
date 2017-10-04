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

    public init(arguments: [String] = CommandLine.arguments,
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

        guard arguments.command == .update else {
            print(Arguments.description)
            return
        }

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

        let path = try fastfileService.updateSharedFastlaneIfNeeded(fromRemotePath: url.absoluteString,
                                                                    version: version)
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
