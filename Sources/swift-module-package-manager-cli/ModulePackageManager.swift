//
//  ModulePackageManager.swift
//  swift-module-package-manager
//
//  Created by 陸瑋恩 on 2025/8/10.
//

import ArgumentParser
import Foundation
import SwiftModulePackageManager

@main
struct ModulePackageManager: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-module-package",
        abstract: "Generate a Swift Package Manager template.",
        subcommands: [Init.self]
    )
}

struct Init: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize a new Swift package."
    )
    
    @Option(name: .long, help: "The name of the package.")
    var name: String = FileManager.default.currentDirectoryPath.components(separatedBy: "/").last ?? "swift-module-package"
    
    func run() throws {
        let fileManager = FileManager.default
        let currentDirectory = fileManager.currentDirectoryPath
        let packageFilePath = "\(currentDirectory)/Package.swift"
        
        guard !fileManager.fileExists(atPath: packageFilePath) else {
            throw RunError("`Package.swift` already exists.")
        }
        var packageContent = try SwiftModulePackageManager.getContent(file: .packageModule)
        packageContent += "\n// MARK: - Module Definitions"
        packageContent += "\n\(try SwiftModulePackageManager.getContent(file: .packageModuleInternal))"
        packageContent += "\n\(try SwiftModulePackageManager.getContent(file: .packageModuleExternal))"
        packageContent += "\n// MARK: - Generate Package"
        packageContent += "\n\(try SwiftModulePackageManager.getContent(file: .generatePackage).replacingOccurrences(of: "<#your-package-name#>", with: name))"
        
        try packageContent.write(toFile: packageFilePath, atomically: true, encoding: .utf8)
        print("`Package.swift` created successfully")
        
        try fileManager.createDirectory(atPath: "\(currentDirectory)/Sources/", withIntermediateDirectories: true)
        try fileManager.createDirectory(atPath: "\(currentDirectory)/Tests/", withIntermediateDirectories: true)
    }
    
    struct RunError: Error, CustomStringConvertible {
        let description: String
        
        init(_ message: String) {
            self.description = message
        }
    }
}
