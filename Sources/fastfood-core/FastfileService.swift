//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import Foundation
import Files

public final class FastfileService {

    enum Error: Swift.Error {
        case noTags
        case fastfileUpdatingFailed
        case fastfileReadingFailed(path: String)
        case fastfoodFolderReadingFailed
    }

    private enum Keys {
        static let fastfoodPath = "/usr/local/bin/.fastfood"
        static let fastfile = "Fastfile"
        static let fastfilePath = "fastlane/Fastfile"
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

    /// Updates shared Fastfile. It checks local version and clones a new one if needed.
    ///
    /// - Parameters:
    ///   - path: A path for remote repository.
    ///   - branch: A tag or a branch of remote repository. Default value is nil.
    ///   - fastfilePath: a path to Fastfile. Converts to `fastlane/Fastfile` in case of `nil`.
    /// - Returns: A path to shared Fastfile.
    /// - Throws: `FastfileService.Error` errors.
    @discardableResult
    func updateSharedFastfileIfNeeded(fromRemotePath remotePath: String,
                                      version: String? = nil,
                                      fastfilePath: String? = nil) throws -> String {
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
        if let fastfile = try? File(path: fastfileVersionFolderPath + "/" + Keys.fastfilePath) {
            return fastfile.path
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
        let fastfilePath = fastfileVersionFolderPath + "/" + Keys.fastfilePath
        do {
            let fastfile = try File(path: fastfilePath)
            return fastfile.path
        }
        catch {
            throw Error.fastfileReadingFailed(path: fastfilePath)
        }

    }

    /// Updates local `Fastfile` in current project directory. Creates a new one if needed.
    ///
    /// - Parameter string: A string for adding.
    /// - Throws: In case of reading or updating errors.
    func updateProjectFastfileIfNeeded(withString string: String) throws {
        do {
            let fastfile = try projectFastfile()
            let fastfileContent = try fastfile.readAsString()
            var fastfileStrings = fastfileContent.components(separatedBy: "\n")
            let index = fastfileStrings.index { $0.contains(Keys.fastfoodPath) }
            if let index = index {
                fastfileStrings[index] = string
            }
            else {
                fastfileStrings.insert(string, at: 0)
            }
            try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
        }
        catch {
            throw Error.fastfileUpdatingFailed
        }
    }

    /// Copies files at paths to fastlane folder.
    ///
    /// - Parameter paths: the paths to the files for copying.
    func copyFilesIfNeeded(atPaths paths: [String]) {
        guard let fastlaneFolder = try? Folder.current.createSubfolderIfNeeded(withName: "fastlane") else {
            return
        }
        paths.forEach { path in
            let envFile = try? File(path: path)
            try? envFile?.copy(to: fastlaneFolder)
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
        case .fastfileUpdatingFailed: return "Fastfile can't be founded or updated."
        case .fastfileReadingFailed(let path): return "Remote repository doesn't contain Fastfile at path: \(path)."
        case .fastfoodFolderReadingFailed: return "Can't find fastfood folder."
        }
    }
}
