//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

import Foundation

public final class Fastfood {
    
    enum Error: Swift.Error {
        case missingArguments
        case noTags
        case fastfileUpdatingFailed
    }
    
    private enum Keys {
        static let fastfoodPath = "/usr/local/bin/.fastfood"
        static let fastfile = "Fastfile"
    }
    
    private var arguments: [String]
    private let fileSystem: FileSystem
    private let gitService: GitService
    
    public init(arguments: [String] = CommandLine.arguments,
                fileSystem: FileSystem = .init(),
                gitService: GitService = .init()) {
        self.arguments = arguments
        self.fileSystem = fileSystem
        self.gitService = gitService
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
    
    @discardableResult
    private func updateLocalFastfile(fromPath path: String) throws -> File {
        let tempPath = Keys.fastfoodPath + "/tmp"
        
        func deleteTemp() {
            try? Folder(path: tempPath).delete()
        }
        
        deleteTemp()
        
        let tags = try gitService.tags(from: path).map(Tag.init)
        guard let lastTag = tags.last else {
            throw Error.noTags
        }
        let taggedFastfileName = Keys.fastfile + "-\(lastTag.version)"
        let fastfoodFolder = try Folder(path: Keys.fastfoodPath)
        if let file = try? File(path: fastfoodFolder.path + taggedFastfileName + "/" + Keys.fastfile) {
            return file
        }
        gitService.clone(fromPath: path, toLocalPath: tempPath)
        gitService.checkout(path: tempPath, tag: lastTag.version)
        let fastfile = try File(path: tempPath + "/" + Keys.fastfile)
        try? fastfoodFolder.file(named: Keys.fastfile).delete()
        let subfolder = try fastfoodFolder.createSubfolderIfNeeded(withName: taggedFastfileName)
        try fastfile.move(to: subfolder)
        deleteTemp()
        return fastfile
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
