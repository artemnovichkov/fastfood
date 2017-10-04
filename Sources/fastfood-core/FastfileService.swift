//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class FastfileService {

    enum Error: Swift.Error {
        case noTags
        case fastlaneUpdatingFailed
    }

    private enum Keys {
        static let fastfoodPath = "/usr/local/bin/.fastfood"
        static let fastfile = "Fastfile"
    }

    private let fileSystem: FileSystem
    private let gitService: GitService

    public init(fileSystem: FileSystem = .init(), gitService: GitService = .init()) {
        self.fileSystem = fileSystem
        self.gitService = gitService
    }

    /// Creates version from project Fastfile import.
    ///
    /// - Returns: a version from Fastfile import.
    func version() -> String? {
        do {
            let fastfile = try projectFastfile()
            let fastfileContent = try fastfile.readAsString()
            let fastfileStrings = fastfileContent.components(separatedBy: "\n")
            let fastfoodImport = fastfileStrings.first { $0.contains(Keys.fastfoodPath) }
            guard let unwrappedImport = fastfoodImport,
                let fastfoodPathRange = unwrappedImport.range(of: Keys.fastfoodPath + "/" + Keys.fastfile + "-") else {
                    return nil
            }
            let substring = String(unwrappedImport[fastfoodPathRange.upperBound...])
            let slashRange = substring.range(of: "/")!
            let version = substring[..<slashRange.lowerBound]
            return String(version)
        }
        catch {
            return nil
        }
    }

    /// Updates shared Fastlane. It checks local version and clones a new one if needed.
    ///
    /// - Parameters:
    ///   - path: A path for remote repository.
    ///   - version: A tag or a branch of remote repository. Default value is nil.
    ///   - checkCache: Check local saved fastlane.
    /// - Returns: A path to shared Fastlane folder.
    /// - Throws: `FastfileService.Error` errors.
    @discardableResult
    func updateSharedFastlaneIfNeeded(fromRemotePath remotePath: String,
                                      version: String? = nil,
                                      checkCache: Bool) throws -> String {
        let finalVersion: String
        if let version = version {
            finalVersion = version
        }
        else {
            let tag = try gitService.tags(from: remotePath).map(Tag.init).first
            if let versionTag = tag {
                finalVersion = versionTag.version
            }
            else {
                throw Error.noTags
            }
        }
        let fastfileVersionFolderPath = Keys.fastfoodPath + "/" + Keys.fastfile + "-" + finalVersion
        if checkCache {
            if let fastlaneFolder = try? Folder(path: fastfileVersionFolderPath) {
                return fastlaneFolder.path
            }
        }
        else {
            try? Folder(path: fastfileVersionFolderPath).delete()
        }

        print("🦄 Clone \(remotePath)...")
        try gitService.clone(fromPath: remotePath, toLocalPath: fastfileVersionFolderPath)

        let tag = try gitService.tags(from: remotePath).map(Tag.init).first { $0.version == finalVersion }
        if let versionTag = tag {
            try gitService.checkout(path: fastfileVersionFolderPath, tag: versionTag.version)
        }
        else {
            try gitService.checkout(path: fastfileVersionFolderPath, branch: finalVersion)
        }
        return fastfileVersionFolderPath + "/"
    }

    /// Updates Fastlane in current project directory. Creates a new one if needed.
    ///
    /// - Parameter path: A path to cached fastlane folder.
    /// - Throws: In case of reading or updating errors.
    func updateProjectFastlaneIfNeeded(withPath path: String) throws {
        do {
            let projectFastlaneFolder = try fileSystem.currentFolder.createSubfolderIfNeeded(withName: "fastlane")
            let sharedFastlaneFolder = try Folder(path: path)
            try sharedFastlaneFolder.subfolders.forEach { subfolder in
                try? projectFastlaneFolder.subfolder(named: subfolder.name).delete()
                try subfolder.copy(to: projectFastlaneFolder)
            }
            try sharedFastlaneFolder.makeFileSequence(recursive: false, includeHidden: true).forEach { file in
                let isProtected = [".env", "Appfile"].contains(file.name)
                let localFile = try? projectFastlaneFolder.file(named: file.name)
                if !isProtected {
                    try localFile?.delete()
                    try file.copy(to: projectFastlaneFolder)
                }
                else if localFile == nil {
                    try file.copy(to: projectFastlaneFolder)
                }
            }
        }
        catch {
            throw Error.fastlaneUpdatingFailed
        }
    }

    // MARK: - Private

    private func projectFastfile() throws -> File {
        let fastlaneFolder = try fileSystem.currentFolder.createSubfolderIfNeeded(withName: "fastlane")
        return try fastlaneFolder.createFileIfNeeded(withName: Keys.fastfile)
    }
}

private extension Array where Element == String {

    func joinedPath() -> Element {
        return joined(separator: "/")
    }
}

extension FastfileService.Error: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .noTags: return "Tag can't be founded."
        case .fastlaneUpdatingFailed: return "Fastfile can't be founded or updated."
        }
    }
}
