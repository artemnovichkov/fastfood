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

    /// Creates tag from project Fastfile import.
    ///
    /// - Returns: a tag from Fastfile import.
    func tag() -> String? {
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
            let tag = substring[..<slashRange.lowerBound]
            return String(tag)
        }
        catch {
            return nil
        }
    }

    /// Updates shared Fastfile. It checks local version and clones a new one if needed.
    ///
    /// - Parameters:
    ///   - path: A path for remote repository.
    ///   - tag: A tag for check. Default value is nil.
    ///   - branch: A branch of remote repository. Default value is nil.
    ///   - fastfilePath: a path to Fastfile. Converts to `fastlane/Fastfile` in case of `nil`.
    /// - Returns: A shared file with needed content.
    /// - Throws: `FastfileService.Error` errors.
    @discardableResult
    func updateSharedFastfileIfNeeded(fromRemotePath remotePath: String,
                                      tag: String? = nil,
                                      branch: String? = nil,
                                      fastfilePath: String? = nil) throws -> String {
        let tags = try gitService.tags(from: remotePath).map(Tag.init)
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
        let taggedFastfileName = [Keys.fastfile, tag].joined(separator: "-")

        let fastfoodFolder: Folder
        do {
            fastfoodFolder = try Folder(path: Keys.fastfoodPath)
        }
        catch {
            throw Error.fastfoodFolderReadingFailed
        }

        let fastfilesPath = fastfoodFolder.path + taggedFastfileName

        if let file = try? File(path: [fastfoodFolder.path + taggedFastfileName, Keys.fastfile].joinedPath()) {
            return file.path
        }

        let fastfilesFolder = try? Folder(path: fastfilesPath)
        if fastfilesFolder == nil {
            print("🦄 Clone \(remotePath)...")
            try gitService.clone(fromPath: remotePath, toLocalPath: fastfilesPath, branch: branch)
        }
        try gitService.checkout(path: fastfilesPath, tag: tag)

        let filePath = fastfilePath ?? Keys.fastfilePath
        do {
            let fastfile = try File(path: [fastfilesPath, filePath].joinedPath())
            return fastfile.path
        }
        catch {
            throw Error.fastfileReadingFailed(path: filePath)
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
