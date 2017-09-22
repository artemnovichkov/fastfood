//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

import Foundation

public final class Fastfood {
    
    enum Error: Swift.Error {
        case missingArguments
        case fastfileUpdatingFailed
    }
    
    private enum Keys {
        static let fastfoodPath = "/usr/local/bin/.fastfood"
        static let fastfile = "Fastfile"
    }
    
    private var arguments: [String]
    private let fileSystem: FileSystem
    
    public init(arguments: [String] = CommandLine.arguments, fileSystem: FileSystem = .init()) {
        self.arguments = arguments
        self.fileSystem = fileSystem
    }
    
    public func run() throws {
        arguments.remove(at: 0)
        guard arguments.count == 1 else {
            throw Error.missingArguments
        }
        let path = arguments[0]
        
        let fastfile = try updateLocalFastfile(fromPath: path)
        try updateFastfileIfNeeded(withString: "import \(fastfile.path)")
        print("🚀 Done!")
    }
    
    private func tags(from path: String) -> [String] {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "ls-remote", "--refs", "-t", path]
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
    
    @discardableResult
    private func updateLocalFastfile(fromPath path: String) throws -> File {
        let tempPath = Keys.fastfoodPath + "/tmp"
        try? Folder(path: tempPath).delete()
        let tags = try self.tags(from: path).map(Tag.init)
        guard let lastTag = tags.last else {
            //TODO: add correct error
            throw Error.fastfileUpdatingFailed
        }
        let taggedFastfileName = Keys.fastfile + "-\(lastTag.version)"
        let fastfoodFolder = try Folder(path: Keys.fastfoodPath)
        if let file = try? File(path: fastfoodFolder.path + taggedFastfileName + "/" + Keys.fastfile) {
            return file
        }
        clone(fromPath: path, toLocalPath: tempPath)
        checkout(path: tempPath, tag: lastTag.version)
        let fastfile = try File(path: tempPath + "/" + Keys.fastfile)
        try? fastfoodFolder.file(named: Keys.fastfile).delete()
        let subfolder = try fastfoodFolder.createSubfolderIfNeeded(withName: taggedFastfileName)
        try fastfile.move(to: subfolder)
        try? Folder(path: tempPath).delete()
        return fastfile
    }
    
    private func clone(fromPath path: String, toLocalPath localPath: String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "clone", path, localPath]
        process.launch()
        process.waitUntilExit()
    }
    
    private func checkout(path: String, tag: String) {
        let process = Process()
        process.currentDirectoryPath = path
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "checkout", "tags/" + tag]
        process.launch()
        process.waitUntilExit()
    }
    
    @discardableResult
    private func updateFastfileIfNeeded(withString string: String) throws -> File {
        do {
            let fastfile = try projectFastfile()
            let fastfileContent = try fastfile.readAsString()
            var fastfileStrings = fastfileContent.components(separatedBy: "\n")
            if !fastfileStrings.contains(string) {
                fastfileStrings.insert(string, at: 0)
                try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
            }
            return fastfile
        }
        catch {
            throw Error.fastfileUpdatingFailed
        }
    }
    
    private func projectFastfile() throws -> File {
        let fastlaneFolder = try fileSystem.currentFolder.createSubfolderIfNeeded(withName: "fastlane")
        return try fastlaneFolder.createFileIfNeeded(withName: Keys.fastfile)
    }
}
