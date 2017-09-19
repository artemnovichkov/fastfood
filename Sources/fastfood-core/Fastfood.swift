//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

import Foundation

public final class Fastfood {
    
    enum Error: Swift.Error {
        case fastfileUpdatingFailed
    }
    
    enum Keys {
        static let fastfoodPath = "/usr/local/bin/.fastfood"
    }
    
    private let arguments: [String]
    private let fileSystem: FileSystem
    
    public init(arguments: [String] = CommandLine.arguments, fileSystem: FileSystem = .init()) {
        self.arguments = arguments
        self.fileSystem = fileSystem
    }
    
    public func run() throws {
        let fastfoodFolder = try fileSystem.createFolderIfNeeded(at: Keys.fastfoodPath)
        
        if !fastfoodFolder.containsFile(named: "Fastfile") {
            let data = try load(path: "https://github.com/artemnovichkov/fastfile-test", tag: "1.0")
            try save(data: data, to: fastfoodFolder)
        }
        try updateFastfileIfNeeded(withImport: "import \(Keys.fastfoodPath)/Fastfile")
    }
    
    private func load(path: String, tag: String) throws -> Data {
        let url = URL(string: path + "/archive/" + tag + ".zip")!
        return try Data(contentsOf: url)
    }
    
    private func save(data: Data, to folder: Folder) throws {
        try fileSystem.createFile(at: folder.path + "fastfile-test.zip", contents: data)
        unzip(input: Keys.fastfoodPath + "/fastfile-test", output: Keys.fastfoodPath)
        let fastfile = try? File(path: folder.path + "fastfile-test-1.0/Fastfile")
        try fastfile?.move(to: folder)
    }
    
    private func unzip(input: String, output: String) {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["unzip", input, "-d", output]
        process.launch()
        process.waitUntilExit()
    }
    
    private func updateFastfileIfNeeded(withImport import: String) throws {
        do {
            let fastlaneFolder = try fileSystem.currentFolder.createSubfolderIfNeeded(withName: "fastlane")
            let fastfile = try fastlaneFolder.createFileIfNeeded(withName: "Fastfile")
            let fastfileContent = try fastfile.readAsString()
            var fastfileStrings = fastfileContent.components(separatedBy: "\n")
            if !fastfileStrings.contains(`import`) {
                fastfileStrings.insert(`import`, at: 0)
            }
            try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
        }
        catch {
            throw Error.fastfileUpdatingFailed
        }
    }
}
