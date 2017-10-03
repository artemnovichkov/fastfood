//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

/// A service for git commands
public final class GitService {

    enum Error: Swift.Error {
        case processFailed(status: Int32, message: String)
    }

    public init() {

    }

    /// Executes `ls-remote` command for tags only.
    ///
    /// - Parameter path: A path to remote repository.
    /// - Returns: An array of tag references.
    func tags(from path: String) throws -> [String] {
        var output = [String]()

        if var string = try process(arguments: ["git", "ls-remote", "--refs", "-t", path]) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }

        return output
    }

    /// Clones a remote repository
    ///
    /// - Parameters:
    ///   - path: A path to remote repository.
    ///   - localPath: A path to local folder.
    ///   - branch: A branch of remote repository. Default value is nil.
    func clone(fromPath path: String, toLocalPath localPath: String, branch: String? = nil) throws {
        var arguments = ["git", "clone", path, localPath, "--quiet"]
        if let branch = branch {
            arguments.append(contentsOf: ["-b", branch])
        }
        try process(arguments: arguments)
    }

    /// Checkouts for passed tag.
    ///
    /// - Parameters:
    ///   - path: A path to remote repository.
    ///   - tag: A tag for checkout.
    func checkout(path: String, tag: String) throws {
        try process(launchPath: path, arguments: ["git", "checkout", "tags/" + tag, "--quiet"])
    }

    /// Checkouts for passed branch.
    ///
    /// - Parameters:
    ///   - path: A path to remote repository.
    ///   - branch: A branch for checkout.
    func checkout(path: String, branch: String) throws {
        try process(launchPath: path, arguments: ["git", "checkout", branch])
    }

    // MARK: - Private

    @discardableResult
    private func process(launchPath: String? = nil, arguments: [String]) throws -> String? {
        let process = Process()
        if let launchPath = launchPath {
            process.currentDirectoryPath = launchPath
        }
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments

        var errorData = Data()

        let outputPipe = Pipe()
        process.standardOutput = outputPipe

        let errorPipe = Pipe()
        process.standardError = errorPipe

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            errorData.append(data)
        }

        process.launch()

        let outdata = outputPipe.fileHandleForReading.readDataToEndOfFile()

        process.waitUntilExit()

        if process.terminationStatus != 0 {
            throw Error.processFailed(status: process.terminationStatus, message: errorData.shellString)
        }

        return String(data: outdata, encoding: .utf8)
    }
}

private extension Data {

    var shellString: String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        if output.hasSuffix("\n") {
            return output
        }

        return String(output[..<output.endIndex])
    }
}

extension GitService.Error: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .processFailed(status: _, message: let message): return message
        }
    }
}
