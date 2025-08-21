//
//  SwiftModulePackageManager.swift
//  swift-module-package-manager
//
//  Created by 陸瑋恩 on 2025/8/21.
//

import Foundation

public enum SwiftModulePackageManager {
    public enum File: String {
        case packageModule = "PackageModule"
        case packageModuleInternal = "PackageModule+Internal"
        case packageModuleExternal = "PackageModule+External"
        case generatePackage = "GeneratePackage"
    }
    
    public static func getContent(file: File) throws -> String {
        return try String(contentsOf: Bundle.module.url(forResource: file.rawValue, withExtension: "swift")!, encoding: .utf8)
    }
}
