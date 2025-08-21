// swift-tools-version: 5.7

enum PackageModule {
    case `internal`(Internal)
    case external(External)
    
    enum Internal: CaseIterable {
        // TODO: Add module cases here
        
        var module: Module {
            switch self {}
        }
    }
    
    enum External: CaseIterable {
        // TODO: Add module cases here (if any)
        
        var module: Module {
            switch self {}
        }
    }
}
