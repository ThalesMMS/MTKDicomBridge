// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MTKDicomBridge",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MTKDicomBridge",
            targets: ["MTKDicomBridge"]
        ),
        .executable(
            name: "VolumeRendererComparison",
            targets: ["VolumeRendererComparison"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/ThalesMMS/MTK.git", exact: "1.4.0"),
        .package(url: "https://github.com/ThalesMMS/DICOM-Swift.git", exact: "1.4.0")
    ],
    targets: [
        .target(
            name: "MTKDicomBridge",
            dependencies: [
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "MTKUI", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Swift")
            ],
            path: "Sources/MTKDicomBridge"
        ),
        .testTarget(
            name: "MTKDicomBridgeTests",
            dependencies: [
                "MTKDicomBridge",
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "MTKUI", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Swift")
            ],
            path: "Tests/MTKDicomBridgeTests"
        ),
        .executableTarget(
            name: "VolumeRendererComparison",
            dependencies: [
                "MTKDicomBridge",
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Swift")
            ],
            path: "Benchmarks/VolumeRendererComparison",
            resources: [
                .copy("ReferenceVolumeRayMarching.metal")
            ]
        )
    ]
)
