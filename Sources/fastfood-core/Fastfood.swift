//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

import Foundation

public final class Fastfood {
    
    enum Error: Swift.Error {
        case noURL
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
        let arguments = try Arguments(arguments: self.arguments)
        
        guard let url = arguments.url else {
            print(Arguments.description)
            throw Error.noURL
        }
        
        let fastfile = try updateLocalFastfile(fromPath: url.absoluteString, tag: arguments.tag)
        try updateFastfileIfNeeded(withString: "import \(fastfile.path)")
        print("🚀 Done!")
    }
    
    @discardableResult
    private func updateLocalFastfile(fromPath path: String, tag: String?) throws -> File {
        let tempPath = Keys.fastfoodPath + "/tmp"
        
        func deleteTemp() {
            try? Folder(path: tempPath).delete()
        }
        
        deleteTemp()
        
        let tags = try gitService.tags(from: path).map(Tag.init)
        let selectedTag: String?
        if let tag = tag {
            selectedTag = tags.first { $0.version == tag }?.version
        }
        else {
            selectedTag = tags.last?.version
        }
        guard let tag = selectedTag else {
            throw Error.noTags
        }
        let taggedFastfileName = Keys.fastfile + "-\(tag)"
        let fastfoodFolder = try Folder(path: Keys.fastfoodPath)
        if let file = try? File(path: fastfoodFolder.path + taggedFastfileName + "/" + Keys.fastfile) {
            return file
        }
        gitService.clone(fromPath: path, toLocalPath: tempPath)
        gitService.checkout(path: tempPath, tag: tag)
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
