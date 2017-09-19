import Foundation
import Files

func load() {
    let session = URLSession(configuration: .default)
    let url = URL(string: "https://github.com/artemnovichkov/fastfile-test/archive/1.0.zip")!
    let semaphore = DispatchSemaphore(value: 0)
    let task = session.dataTask(with: url) { data, response, error in
        guard let data = data else {
            return
        }
        let file = try? FileSystem().createFile(at: "/usr/local/bin/.fastfood/fastfile-test.zip", contents: data)
        unzip()
        
        let fastfile = try? File(path: "/usr/local/bin/.fastfood/fastfile-test-1.0/Fastfile")
        let fastfoodFolder = try? Folder(path: "/usr/local/bin/.fastfood/")
        try? fastfile?.move(to: fastfoodFolder!)
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
}

func unzip() {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["unzip", "/usr/local/bin/.fastfood/fastfile-test", "-d", "/usr/local/bin/.fastfood/"]
    process.launch()
    process.waitUntilExit()
}

func updateFastfile() {
    do {
        let fastlaneFolder = try FileSystem().currentFolder.createSubfolderIfNeeded(withName: "fastlane")
        let fastfile = try fastlaneFolder.createFileIfNeeded(withName: "Fastfile")
        let fastfileContent = try fastfile.readAsString()
        var fastfileStrings = fastfileContent.components(separatedBy: "\n")
        let neededImport = "import ~/.fastfood/Fastfile"
        if !fastfileStrings.contains(neededImport) {
            fastfileStrings.insert(neededImport, at: 0)
        }
        try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
    }
    catch {
        print(error)
    }
}

//Main logic
let fastfoodFolder = try FileSystem().createFolderIfNeeded(at: "/usr/local/bin/.fastfood")
if !fastfoodFolder.containsFile(named: "Fastfile") {
    load()
}
updateFastfile()
print("Finish")

