import Cocoa

struct Task {

  static func output(launchPath: String, arguments: [String],
                     directoryPath: URL? = nil) -> String {

    let output = Pipe()
    
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = output

    if let path = directoryPath?.removeTrailingSlash.path {
      task.currentDirectoryPath = path
    }

    task.launch()

    // For some reason [task waitUntilExit]; does not return sometimes. Therefore this rather hackish solution:
    var count = 0;
    while task.isRunning && count < 10 {
      Thread.sleep(forTimeInterval: 0.1)
      count += 1
    }

    let data = output.fileHandleForReading.readDataToEndOfFile()
    guard let result = String(data: data, encoding: .utf8) else {
      return ""
    }

    return result
  }
}
