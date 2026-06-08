# MTKDicomBridge

![Swift 5.10](https://img.shields.io/badge/Swift-5.10-orange.svg)
![iOS 17+](https://img.shields.io/badge/iOS-17%2B-lightgrey.svg)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-lightgrey.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)

MTKDicomBridge connects `DICOM-Swift` data models to MTK's Metal-native rendering and clinical viewer APIs. It keeps DICOM parsing outside `MTKCore` while providing ready-to-use adapters for volume import, overlays, structured reports, presentation states, clinical non-image objects, and viewer annotation round trips.

Use this package when your app already depends on MTK for rendering and wants the default Swift DICOM ingestion path from `DICOM-Swift`.

## What It Provides

- `DicomVolumeDatasetImporter` converts decoded DICOM series and progressive volume updates into `MTKCore.VolumeDataset` values with spacing, orientation, intensity range, recommended window, and clinical metadata.
- `DicomSegmentationVolumeLayerBuilder`, `DicomRTStructureContourOverlayBuilder`, and `DicomRTDoseVolumeOverlayBuilder` map DICOM SEG, RTSTRUCT, and RTDOSE objects into MTK labelmaps, surface meshes, contour overlays, and dose overlays.
- `DicomPETFusionLayerBuilder` and `DicomParametricMapScalarLayerBuilder` build quantitative scalar layers for registered PET and DICOM Parametric Map overlays.
- `DicomStructuredReportViewerBridge`, `DicomPresentationStateMPRBridge`, and `DicomKeyObjectSelectionNavigationBridge` adapt SR, PR, CAD findings, measurements, and key-image references into MTKUI viewer state.
- `DicomClinicalObjectImporter` and `DicomClinicalObjectDisplayBridge` expose supported encapsulated documents, waveforms, and videos as MTKUI clinical object display items.
- `ViewerROIDicomRoundTrip` and `VolumeMaskDicomSegmentationExporter` export viewer measurements, presentation-state annotations, and edited volume masks back to DICOM data sets or Part 10 files.
- `VolumeRendererComparison` provides a local benchmark executable for comparing MTK volume rendering behavior against a reference ray-marching shader.

## Package Layout

```text
Sources/MTKDicomBridge/              Public bridge APIs
Tests/MTKDicomBridgeTests/           Unit and integration coverage
Benchmarks/VolumeRendererComparison/ Metal volume-rendering comparison tool
Package.swift                        SwiftPM manifest
```

## Requirements

- Swift 5.10
- iOS 17+ or macOS 14+
- Metal-capable Apple platform for rendering paths and GPU smoke coverage
- Public SwiftPM dependencies:
  - [`MTK`](https://github.com/ThalesMMS/MTK) exact `1.2.1`
  - [`DICOM-Swift`](https://github.com/ThalesMMS/DICOM-Swift) exact `1.3.1`

## Related Repositories

- [MTK](https://github.com/ThalesMMS/MTK) — Metal rendering core, SwiftUI viewports, and synthetic fixtures.
- [DICOM-Swift](https://github.com/ThalesMMS/DICOM-Swift) — Swift DICOM parsing, ZIP loading, metadata extraction, and decoded series assembly.
- [MTKDicomBridge](https://github.com/ThalesMMS/MTKDicomBridge) — This bridge package for converting DICOM-Swift models into MTK datasets and viewer state.
- [MTK-Demo](https://github.com/ThalesMMS/MTK-Demo) — Public demo app that consumes the release-tagged packages together.

## Add Via Swift Package Manager

```swift
.package(url: "https://github.com/ThalesMMS/MTKDicomBridge.git", exact: "1.0.0")
```

Then depend on the library product:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "MTKDicomBridge", package: "MTKDicomBridge")
    ]
)
```

SwiftPM resolves MTK and DICOM-Swift from the exact public tags declared by this package. Add a direct `DICOM-Swift` dependency only if your application imports `DicomCore` itself.

## Basic Volume Import

```swift
import Foundation
import MTKCore
import MTKDicomBridge

let importer = DicomVolumeDatasetImporter()

importer.loadDataset(
    from: studyURL,
    progress: { update in
        switch update {
        case .started(let totalSlices):
            print("Reading \(totalSlices) slices")
        case .reading(let fraction, let slicesLoaded):
            print("Loaded \(slicesLoaded) slices: \(fraction)")
        }
    },
    completion: { result in
        switch result {
        case .success(let imported):
            let dataset: VolumeDataset = imported.dataset
            print("Ready for MTK rendering:", dataset.dimensions)
        case .failure(let error):
            print("DICOM import failed:", error)
        }
    }
)
```

## Overlay Examples

```swift
let segmentationOverlay = try DicomSegmentationVolumeLayerBuilder.makeOverlay(
    from: segmentation,
    alignedTo: baseDataset
)

let doseOverlay = try DicomRTDoseVolumeOverlayBuilder.makeOverlay(
    from: rtDose,
    alignedTo: baseDataset
)

let presentationState = DicomPresentationStateMPRBridge.makePresentationState(
    from: grayscalePresentationState,
    options: DicomPresentationStateMPRBridgeOptions(
        axis: .axial,
        imageWidth: 512,
        imageHeight: 512
    )
)
```

## Benchmark

Run the comparison executable with a local DICOM file, directory, or ZIP archive:

```sh
swift run VolumeRendererComparison --dicom /path/to/study --frames 60 --size 512
```

The benchmark requires a Metal device and uses `ReferenceVolumeRayMarching.metal` from `Benchmarks/VolumeRendererComparison`.

## Tests

```sh
swift test
```

Some tests exercise Metal texture upload paths and skip when Metal is unavailable.

## Intended Use And Safety

MTKDicomBridge is an integration package for research, education, prototyping, and application development involving DICOM-derived volumetric data on Apple platforms. It is not a medical device, has not been validated for clinical decision-making, and should not be used as the sole basis for diagnosis, treatment, or patient triage.

Applications that load real DICOM data remain responsible for PHI handling, local security, regulatory obligations, validation, and institutional review requirements.

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).

Copyright 2026 Thales Matheus Mendonça Santos.
