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
        .package(url: "https://github.com/ThalesMMS/MTK.git", exact: "1.3.1"),
        .package(url: "https://github.com/ThalesMMS/DICOM-Decoder.git", exact: "1.3.3")
    ],
    targets: [
        .target(
            name: "MTKDicomBridge",
            dependencies: [
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "MTKUI", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Decoder")
            ],
            path: "Sources/MTKDicomBridge"
        ),
        .testTarget(
            name: "MTKDicomBridgeTests",
            dependencies: [
                "MTKDicomBridge",
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "MTKUI", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Decoder")
            ],
            path: "Tests/MTKDicomBridgeTests"
        ),
        .executableTarget(
            name: "VolumeRendererComparison",
            dependencies: [
                "MTKDicomBridge",
                .product(name: "MTKCore", package: "MTK"),
                .product(name: "DicomCore", package: "DICOM-Decoder")
            ],
            path: "Benchmarks/VolumeRendererComparison",
            resources: [
                .copy("ReferenceVolumeRayMarching.metal")
            ]
        )
    ]
)
