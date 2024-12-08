// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "Phasor",
    dependencies: [
        .package(url: "https://github.com/SwiftyLab/MetaCodable", .upToNextMajor(from: "1.4.0"))
    ]
)
