//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation

public class GitService {
    
    public init() {
        
    }
    
    func tags(from path: String) -> [String] {
        let process = self.process(arguments: ["git", "ls-remote", "--refs", "-t", path])
        let outpipe = Pipe()
        process.standardOutput = outpipe
        process.launch()
        
        var output = [String]()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        process.waitUntilExit()
        return output
    }
    
    func clone(fromPath path: String, toLocalPath localPath: String) {
        let process = self.process(arguments: ["git", "clone", path, localPath])
        process.launch()
        process.waitUntilExit()
    }
    
    func checkout(path: String, tag: String) {
        let process = self.process(launchPath: path, arguments: ["git", "checkout", "tags/" + tag])
        process.launch()
        process.waitUntilExit()
    }
    
    private func process(launchPath: String? = nil, arguments: [String]) -> Process {
        let process = Process()
        if let launchPath = launchPath {
            process.currentDirectoryPath = launchPath
        }
        process.launchPath = "/usr/bin/env"
        process.arguments = arguments
        return process
    }
}
