import Foundation
import Library
import SnapshotTesting
import UIKit

// Represents a single screenshot configuration (device, locale, style, font, orientation).
internal struct ScreenshotType {
  internal let device: Device
  internal let language: Language
  internal let style: UIUserInterfaceStyle
  internal let contentSizeCategory: UIContentSizeCategory
  internal let orientation: Orientation
}

// Iterates through default screenshot configs using orthogonal sampling.
/// Iterates over a representative set of screenshot configs using orthogonal sampling to avoid
/// full Cartesian explosion while ensuring each dimension is covered at least once.
internal func forEachScreenshotType(
  devices: [Device] = Device.allCases,
  languages: [Language] = Language.allLanguages,
  styles: [UIUserInterfaceStyle] = [.light, .dark],
  contentSizes: [UIContentSizeCategory] = [
    .medium,
    .accessibilityExtraExtraExtraLarge
  ],
  orientation: Orientation = .portrait,
  body: (ScreenshotType) -> Void
) {
  orthogonalCombos(devices, languages, styles, contentSizes).forEach {
    device, language, style, contentSize in
    body(
      ScreenshotType(
        device: device,
        language: language,
        style: style,
        contentSizeCategory: contentSize,
        orientation: orientation
      )
    )
  }
}

/// Configures environment, traits, style, font size, and naming before asserting a snapshot.
internal func assertSnapshot(
  forController controller: UIViewController,
  withType type: ScreenshotType,
  perceptualPrecision: Float? = nil,
  record: Bool = false,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  let contentSizeTraits = UITraitCollection(
    preferredContentSizeCategory: type.contentSizeCategory
  )

  withEnvironment(language: type.language) {
    let (parent, _) = traitControllers(
      device: type.device,
      orientation: type.orientation,
      child: controller,
      additionalTraits: contentSizeTraits
    )

    controller.overrideUserInterfaceStyle = type.style

    if let testScheduler = AppEnvironment.current.scheduler as? TestScheduler {
      testScheduler.run()
    }

    let name = snapshotName(
      file: file,
      function: testName,
      type: type
    )

    let strategy: Snapshotting<UIView, UIImage>
    if let precision = perceptualPrecision {
      strategy = .image(perceptualPrecision: precision)
    } else {
      strategy = .image
    }

    assertSnapshot(
      matching: parent.view,
      as: strategy,
      named: name,
      record: record,
      file: file,
      testName: testName,
      line: line
    )
  }
}


/// Builds a consistent snapshot name from file, function, and the screenshot configuration.
private func snapshotName(
  file: StaticString,
  function: String,
  type: ScreenshotType
) -> String {
  let fileComponent = sanitizeSnapshotComponent(
    URL(fileURLWithPath: "\(file)").deletingPathExtension().lastPathComponent
  )

  let functionComponent = sanitizeSnapshotComponent(
    function.replacingOccurrences(of: "()", with: "")
  )

  let deviceComponent = sanitizeSnapshotComponent(type.device.snapshotDescription)
  let languageComponent = sanitizeSnapshotComponent(type.language.rawValue)
  return [
    fileComponent,
    functionComponent,
    deviceComponent,
    languageComponent
  ]
  .joined(separator: "_")
}

/// Makes a snapshot name component safe by allowing only alphanumerics.
private func sanitizeSnapshotComponent(_ value: String) -> String {
  let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
  return value
    .replacingOccurrences(of: " ", with: "-")
    .unicodeScalars
    .map { allowed.contains($0) ? Character($0) : "-" }
    .reduce("") { $0 + String($1) }
}

private extension Device {
  var snapshotDescription: String {
    switch self {
    case .phone4inch: return "phone4inch"
    case .phone4_7inch: return "phone4_7inch"
    case .phone5_5inch: return "phone5_5inch"
    case .phone5_8inch: return "phone5_8inch"
    case .pad: return "pad"
    }
  }
}

private extension Orientation {
  var snapshotDescription: String {
    switch self {
    case .portrait: return "portrait"
    case .landscape: return "landscape"
    }
  }
}

