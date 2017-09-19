import Foundation
import Files

func load() {
    let session = URLSession(configuration: .default)
    let url = URL(string: "https://github.com/artemnovichkov/Carting/archive/1.2.6.zip")!
    let semaphore = DispatchSemaphore(value: 0)
    let task = session.dataTask(with: url) { data, response, error in
        guard let data = data else {
            return
        }
        let file = try? FileSystem().createFile(at: "carting.zip", contents: data)
        unzip()
        let makefile = try? FileSystem().currentFolder.file(atPath: "Carting-1.2.6/Makefile")
        let string = try? makefile?.readAsString()
        print(string)
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
}

func unzip() {
    let process = Process()
    process.launchPath = "/usr/bin/env"
    process.arguments = ["unzip", "carting"]
    process.launch()
    process.waitUntilExit()
}

//load()

do {
    let fastlaneFolder = try FileSystem().currentFolder.createSubfolderIfNeeded(withName: "fastlane")
    let fastfile = try fastlaneFolder.createFileIfNeeded(withName: "Fastfile")
    let fastfileContent = try fastfile.readAsString()
    var fastfileStrings = fastfileContent.components(separatedBy: "\n")
    let neededImport = "import ~/Fastfile"
    if !fastfileStrings.contains(neededImport) {
        fastfileStrings.insert(neededImport, at: 0)
    }
    try fastfile.write(string: fastfileStrings.joined(separator: "\n"))
    print("Finish")
}
catch {
    print(error)
}
