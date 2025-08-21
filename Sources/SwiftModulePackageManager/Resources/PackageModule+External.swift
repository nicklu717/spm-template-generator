extension PackageModule.External {
    class Module {
        struct PackageInfo {
            let name: String
            let url: String
            let tag: String
        }
        
        let name: String
        let packageInfo: PackageInfo
        
        init(name: String, packageInfo: PackageInfo) {
            self.name = name
            self.packageInfo = packageInfo
        }
    }
}
