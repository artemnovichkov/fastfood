//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

/// A service for git commands
public final class GitService {
    
    public init() {
        
    }
    
    /// Executes `ls-remote` command for tags only.
    ///
    /// - Parameter path: A path to remote repository.
    /// - Returns: An array of tag references.
    func tags(from path: String) -> [String] {
        var output = [String]()
        
        if var string = process(arguments: ["git", "ls-remote", "--refs", "-t", path]) {
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
    func clone(fromPath path: String, toLocalPath localPath: String) {
        process(arguments: ["git", "clone", path, localPath, "--quiet"])
    }
    
    /// Checkouts for passed tag.
    ///
    /// - Parameters:
    ///   - path: A path to remote repository.
    ///   - tag: A tag for checkout.
    func checkout(path: String, tag: String) {
        process(launchPath: path, arguments: ["git", "checkout", "tags/" + tag, "--quiet"])
    }
    
    // MARK: - Private
    
    @discardableResult
    private func process(launchPath: String? = nil, arguments: [String]) -> String? {
        let process = Process()
        if let launchPath = launchPath {
            process.currentDirectoryPath = launchPath
        }
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        
        let outpipe = Pipe()
        process.standardOutput = outpipe
        process.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        
        process.waitUntilExit()
        
        return String(data: outdata, encoding: .utf8)
    }
}
