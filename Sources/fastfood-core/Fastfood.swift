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
        guard arguments.count == 2 else {
            throw Error.missingArguments
        }
        let path = arguments[0]
        let tag = arguments[1]
        let fastfoodFolder = try fileSystem.createFolderIfNeeded(at: Keys.fastfoodPath)
        
        if !fastfoodFolder.containsFile(named: Keys.fastfile) {
            print("Start downloading from \(path)...")
            let data = try load(path: path, tag: tag)
            print("Downloading has finished")
            try save(data: data, withName: "fastfile-test-\(tag)/", to: fastfoodFolder)
        }
        try updateFastfileIfNeeded(withImport: "import \(Keys.fastfoodPath)/" + Keys.fastfile)
        try cleanup(fastfoodFolder)
        print("🚀 Done!")
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
    
    private func cleanup(_ folder: Folder) throws {
        for file in folder.makeFileSequence() {
            if file.name != Keys.fastfile {
                try file.delete()
            }
        }
        try folder.subfolders.forEach { try $0.delete() }
    }
}
