import Foundation
import Files

func load(path: String, tag: String) throws -> Data {
    let url = URL(string: path + "/archive/" + tag + ".zip")!
    return try Data(contentsOf: url)
}

func unzip(input: String, output: String) {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["unzip", input, "-d", output]
    process.launch()
    process.waitUntilExit()
}

func updateFastfileIfNeeded(withImport import: String) {
    do {
        let fastlaneFolder = try FileSystem().currentFolder.createSubfolderIfNeeded(withName: "fastlane")
        let fastfile = try fastlaneFolder.createFileIfNeeded(withName: "Fastfile")
        let fastfileContent = try fastfile.readAsString()
        var fastfileStrings = fastfileContent.components(separatedBy: "\n")
        if !fastfileStrings.contains(`import`) {
            fastfileStrings.insert(`import`, at: 0)
        }
        try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
    }
    catch {
        print(error)
    }
}

func save(data: Data, to folder: Folder) throws {
    try FileSystem().createFile(at: folder.path + "fastfile-test.zip", contents: data)
    unzip(input: "/usr/local/bin/.fastfood/fastfile-test", output: "/usr/local/bin/.fastfood/")
    let fastfile = try? File(path: folder.path + "fastfile-test-1.0/Fastfile")
    try fastfile?.move(to: folder)
}

//Main logic
do {
    let fastfoodFolder = try FileSystem().createFolderIfNeeded(at: "/usr/local/bin/.fastfood")
    
    if !fastfoodFolder.containsFile(named: "Fastfile") {
        let data = try load(path: "https://github.com/artemnovichkov/fastfile-test", tag: "1.0")
        try save(data: data, to: fastfoodFolder)
    }
    updateFastfileIfNeeded(withImport: "import /usr/local/bin/.fastfood/Fastfile")
    print("Finish")
}
catch {
    print(error)
}

