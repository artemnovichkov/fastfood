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
//        let tag = try currentTag() ?? "1.0"
//        let fastfoodFolder = try fileSystem.createFolderIfNeeded(at: Keys.fastfoodPath)
//
//        if !fastfoodFolder.containsFile(named: Keys.fastfile) {
//            print("Start downloading from \(path)...")
//            let data = try load(path: path, tag: tag)
//            print("Downloading has finished")
//            try save(data: data, withName: "fastfile-test-\(tag)/", to: fastfoodFolder)
//        }
//        try updateFastfileIfNeeded(withImport: "import \(Keys.fastfoodPath)/" + Keys.fastfile, tag: tag)
//        try cleanup(fastfoodFolder)
//        print("🚀 Done!")
        try updateLocalFastfile()
    }
    
    func updateLocalFastfile() throws {
        let fastfoodPath = "/usr/local/bin/.fastfood"
        let tempPath = fastfoodPath + "/tmp"
        try? Folder(path: tempPath).delete()
        clone(fromPath: "https://github.com/artemnovichkov/fastfile-test.git",
              toLocalPath: tempPath)
        let fastfoodFolder = try Folder(path: fastfoodPath)
        let fastfile = try File(path: tempPath + "/Fastfile")
        try? fastfoodFolder.file(named: "Fastfile").delete()
        try fastfile.move(to: fastfoodFolder)
        try? Folder(path: tempPath).delete()
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
    
    @discardableResult
    private func updateFastfileIfNeeded(withImport import: String, tag: String) throws -> File {
        do {
            let fastfile = try self.fastfile()
            let fastfileContent = try fastfile.readAsString()
            var fastfileStrings = fastfileContent.components(separatedBy: "\n")
            if let firstString = fastfileStrings.first, firstString.starts(with: "#") {
                fastfileStrings[0] = "#" + tag
            }
            else {
                fastfileStrings.insert("#" + tag, at: 0)
            }
            if !fastfileStrings.contains(`import`) {
                fastfileStrings.insert(`import`, at: 1)
            }
            try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
            return fastfile
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
    
    private func fastfile() throws -> File {
        let fastlaneFolder = try fileSystem.currentFolder.createSubfolderIfNeeded(withName: "fastlane")
        return try fastlaneFolder.createFileIfNeeded(withName: Keys.fastfile)
    }
    
    private func currentTag() throws -> String? {
        let fastfile = try self.fastfile()
        let fastfileContent = try fastfile.readAsString()
        let fastfileStrings = fastfileContent.components(separatedBy: "\n")
        if let firstString = fastfileStrings.first, firstString.starts(with: "#") {
            return firstString.replacingOccurrences(of: "#", with: "")
        }
        return nil
    }
}
