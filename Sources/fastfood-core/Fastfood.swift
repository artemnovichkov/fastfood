//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

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

        let tag = arguments.force ? nil : fastfileService.tag()

        let path = try fastfileService.updateSharedFastfileIfNeeded(fromRemotePath: url.absoluteString,
                                                                    tag: tag,
                                                                    branch: arguments.branch,
                                                                    fastfilePath: arguments.path)
        print("🤖 Updating...")
        try fastfileService.updateProjectFastfileIfNeeded(withString: "import \(path)")
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
