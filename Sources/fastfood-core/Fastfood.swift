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
        //        arguments.remove(at: 0)
        //        guard arguments.count == 1 else {
        //            throw Error.missingArguments
        //        }
        //        let path = arguments[0]
        
                let fastfile = try updateLocalFastfile()
        //        let fastfileStrings = try fastfile.readAsString().components(separatedBy: "\n")
        //        guard let firstString = fastfileStrings.first, firstString.starts(with: "#") else {
        //            //TODO: update error
        //            throw Error.fastfileUpdatingFailed
        //        }
        //        let tagIndex = firstString.index(after: firstString.startIndex)
        //        let tag = firstString[tagIndex...]
        //        print(tag)
        
        //        try updateFastfileIfNeeded(withString: "import \(fastfile.path)", tag: "tag")
                print("🚀 Done!")
    }
    
    func checkout(path: String, tag: String) {
        let process = Process()
        process.currentDirectoryPath = path
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "checkout", "tags/" + tag]
        process.launch()
        process.waitUntilExit()
    }
    
    @discardableResult
    func updateLocalFastfile() throws -> File {
        let fastfoodPath = "/usr/local/bin/.fastfood"
        let tempPath = fastfoodPath + "/tmp"
        try? Folder(path: tempPath).delete()
        let tags = try self.tags().map(Tag.init)
        guard let lastTag = tags.last else {
            //TODO: add correct error
            throw Error.fastfileUpdatingFailed
        }
        clone(fromPath: "https://github.com/artemnovichkov/fastfile-test.git",
              toLocalPath: tempPath)
        checkout(path: tempPath, tag: lastTag.version)
        let fastfoodFolder = try Folder(path: fastfoodPath)
        let fastfile = try File(path: tempPath + "/Fastfile")
        try? fastfoodFolder.file(named: "Fastfile").delete()
        let subfolder = try fastfoodFolder.createSubfolderIfNeeded(withName: "Fastfile-\(lastTag.version)")
        try fastfile.move(to: subfolder)
        try? Folder(path: tempPath).delete()
        return fastfile
    }
    
    private func load(path: String, tag: String) throws -> Data {
        let url = URL(string: path + "/archive/" + tag + ".zip")!
        return try Data(contentsOf: url)
    }
    
    private func save(data: Data, withName name: String, to folder: Folder) throws {
        try fileSystem.createFile(at: folder.path + name + ".zip", contents: data)
        unzip(input: Keys.fastfoodPath + "/" + name, output: Keys.fastfoodPath)
        let fastfile = try File(path: folder.path + name + Keys.fastfile)
        try fastfile.move(to: folder)
    }
    
    private func unzip(input: String, output: String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["unzip", input, "-d", output]
        process.launch()
        process.waitUntilExit()
    }
    
    private func clone(fromPath path: String, toLocalPath localPath: String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "clone", path, localPath]
        process.launch()
        process.waitUntilExit()
    }
    
    func tags() -> [String] {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["git", "ls-remote", "--refs", "-t", "https://github.com/artemnovichkov/fastfile-test.git"]
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
    private func updateFastfileIfNeeded(withString string: String, tag: String) throws -> File {
        do {
            let fastfile = try projectFastfile()
            let fastfileContent = try fastfile.readAsString()
            var fastfileStrings = fastfileContent.components(separatedBy: "\n")
            if let firstString = fastfileStrings.first, firstString.starts(with: "#") {
                fastfileStrings[0] = "#" + tag
            }
            else {
                fastfileStrings.insert("#" + tag, at: 0)
            }
            if !fastfileStrings.contains(string) {
                fastfileStrings.insert(string, at: 1)
            }
            try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
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
