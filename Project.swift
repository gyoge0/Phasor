import ProjectDescription

let project = Project(
    name: "Phasor",
    targets: [
        .target(
            name: "Phasor",
            destinations: .iOS,
            product: .app,
            bundleId: "com.gyoge.Phasor",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSCameraUsageDescription": "Phasor needs access to the camera to provide AR experiences.",
                    "NSMotionUsageDescription": "Phasor needs access to motion data to track your head during dynamic audio experiences."

                ]
            ),
            sources: ["Phasor/Sources/**"],
            resources: ["Phasor/Resources/**"],
            dependencies: [],
            settings: .settings(
                base: [:]
                    .automaticCodeSigning(devTeam: "5J5Q86SD6J")
                    .codeSignIdentityAppleDevelopment()
            )
        ),
        .target(
            name: "PhasorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.gyoge.PhasorTests",
            infoPlist: .default,
            sources: ["Phasor/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Phasor")]
        ),
    ]
)
