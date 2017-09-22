//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

public class GitService {
    
    public init() {
        
    }
    
    func tags(from path: String) -> [String] {
        var output = [String]()
        
        if var string = process(arguments: ["git", "ls-remote", "--refs", "-t", path]) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        return output
    }
    
    func clone(fromPath path: String, toLocalPath localPath: String) {
        process(arguments: ["git", "clone", path, localPath, "--quiet"])
    }
    
    func checkout(path: String, tag: String) {
        process(launchPath: path, arguments: ["git", "checkout", "tags/" + tag, "--quiet"])
    }
    
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
