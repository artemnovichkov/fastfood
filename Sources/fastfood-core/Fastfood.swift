//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

public final class Fastfood {
    
    enum Error: Swift.Error {
        case noURL
    }
    
    private var arguments: [String]
    private let fastfileService: FastfileService
    
    public init(arguments: [String] = CommandLine.arguments,
                fastfileService: FastfileService = .init()) {
        self.arguments = arguments
        self.fastfileService = fastfileService
    }
    
    public func run() throws {
        let arguments = try Arguments(arguments: self.arguments)
        
        guard let url = arguments.url else {
            print(Arguments.description)
            throw Error.noURL
        }
        
        let path = try fastfileService.updateSharedFastfileIfNeeded(fromPath: url.absoluteString, tag: arguments.tag)
        print("🤖 Updating...")
        try fastfileService.updateProjectFastfileIfNeeded(withString: "import \(path)")
        print("🎉 Done!")
    }
}

extension Fastfood.Error: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noURL: return "URL doesn't defined. Use --url parameter."
        }
    }
}
