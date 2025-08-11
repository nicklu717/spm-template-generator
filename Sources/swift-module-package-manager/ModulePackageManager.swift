//
//  ModulePackageManager.swift
//  swift-module-package-manager
//
//  Created by 陸瑋恩 on 2025/8/10.
//

import ArgumentParser

@main
struct ModulePackageManager: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swift-module-package",
        abstract: "Generate a Swift Package Manager template."
    )
}
