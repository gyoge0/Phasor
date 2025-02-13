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
                    "NSCameraUsageDescription":
                        "Phasor needs access to the camera to provide AR experiences.",
                    "NSMotionUsageDescription":
                        "Phasor needs access to motion data to track your head during dynamic audio experiences.",
                    "UTExportedTypeDeclarations": [
                        [
                            "UTTypeIdentifier": "com.gyoge.phasor.phasorproject",
                            "UTTypeConformsTo": [
                                "com.apple.package"
                            ],
                            "UTTypeDescription": "Phasor Project",
                            "UTTypeTagSpecification": [
                                "public.filename-extension": [
                                    "phasorproject"
                                ]
                            ],
                        ]
                    ],
                    "CFBundleDocumentTypes": [
                        [
                            "CFBundleTypeIconFiles": [],
                            "CFBundleTypeName": "Phasor Project",
                            "LSHandlerRank": "Owner",
                            "LSItemContentTypes": [
                                "com.gyoge.phasor.phasorproject"
                            ],
                        ]
                    ],
                    "LSSupportsOpeningDocumentsInPlace": false,
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .external(name: "MetaCodable")
            ],
            settings: .settings(
                base: [:]
                    .automaticCodeSigning(devTeam: "5J5Q86SD6J")
                    .codeSignIdentityAppleDevelopment()
            )
        )
    ]
)
