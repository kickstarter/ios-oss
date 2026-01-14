import Foundation
import Library
import ReactiveSwift
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

// Explicit aliases to SnapshotTesting types to avoid name resolution issues in
// targets that do not import the UIKit-specific extensions by default.
private typealias SnapshotDevice = SnapshotTesting.Device
private typealias SnapshotOrientation = SnapshotTesting.Orientation

// Represents a single screenshot configuration (device, locale, style, font, orientation).
internal struct ScreenshotType {
  internal let device: SnapshotDevice
  internal let language: Language
  internal let style: UIUserInterfaceStyle
  internal let contentSizeCategory: UIContentSizeCategory
  internal let orientation: SnapshotOrientation
}

// Iterates through default screenshot configs using orthogonal sampling.
/// Iterates over a representative set of screenshot configs using orthogonal sampling to avoid
/// full Cartesian explosion while ensuring each dimension is covered at least once.
internal func forEachScreenshotType(
  devices: [SnapshotDevice] = SnapshotDevice.allCases,
  languages: [Language] = Language.allLanguages,
  styles: [UIUserInterfaceStyle] = [.light, .dark],
  contentSizes: [UIContentSizeCategory] = [
    .medium,
    .accessibilityExtraExtraExtraLarge
  ],
  orientation: SnapshotOrientation = .portrait,
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

/// Iterates over screenshot configs plus an additional data set, using orthogonal sampling to keep counts low.
internal func forEachScreenshotType<T>(
  withData data: [T],
  devices: [SnapshotDevice] = SnapshotDevice.allCases,
  languages: [Language] = Language.allLanguages,
  styles: [UIUserInterfaceStyle] = [.light, .dark],
  contentSizes: [UIContentSizeCategory] = [
    .medium,
    .accessibilityExtraExtraExtraLarge
  ],
  orientation: SnapshotOrientation = .portrait,
  body: (ScreenshotType, T) -> Void
) {
  orthogonalCombos(devices, languages, styles, contentSizes, data).forEach {
    device, language, style, contentSize, datum in
    body(
      ScreenshotType(
        device: device,
        language: language,
        style: style,
        contentSizeCategory: contentSize,
        orientation: orientation
      ),
      datum
    )
  }
}

/// Asserts snapshots for all provided (or default) screenshot types, creating a fresh controller each time.
internal func assertAllSnapshots(
  forController controllerProvider: () -> UIViewController,
  types: [ScreenshotType]? = nil,
  perceptualPrecision: Float? = nil,
  record: Bool = false,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  if let types = types {
    types.forEach { type in
      assertSnapshot(
        forController: controllerProvider(),
        withType: type,
        perceptualPrecision: perceptualPrecision,
        record: record,
        file: file,
        testName: testName,
        line: line
      )
    }
  } else {
    forEachScreenshotType { type in
      assertSnapshot(
        forController: controllerProvider(),
        withType: type,
        perceptualPrecision: perceptualPrecision,
        record: record,
        file: file,
        testName: testName,
        line: line
      )
    }
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

  withLanguage(type.language) {
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

    let strategy: Snapshotting<UIView, UIImage> = {
      if let precision = perceptualPrecision {
        return .image(perceptualPrecision: precision)
      }
      return .image
    }()

    let directory = snapshotDirectory(for: file)

    if let failure = verifySnapshot(
      of: parent.view,
      as: strategy,
      named: name,
      record: record,
      snapshotDirectory: directory,
      file: file,
      testName: testName,
      line: line
    ) {
      XCTFail(
        """
        Snapshot failed for \(name)
        device=\(type.device.snapshotDescription),
        lang=\(type.language.rawValue),
        style=\(type.style.snapshotDescription),
        font=\(type.contentSizeCategory.snapshotDescription),
        orientation=\(type.orientation.snapshotDescription)
        \(failure)
        """,
        file: file,
        line: line
      )
    }
  }
}

/// Configures environment, traits, style, font size, and naming before asserting a snapshot of a UIView.
internal func assertSnapshot(
  forView view: UIView,
  withType type: ScreenshotType,
  size: CGSize? = nil,
  useIntrinsicSize: Bool = false,
  perceptualPrecision: Float? = nil,
  record: Bool = false,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  let contentSizeTraits = UITraitCollection(
    preferredContentSizeCategory: type.contentSizeCategory
  )

  let containerController = UIViewController()
  containerController.view.addSubview(view)
  view.translatesAutoresizingMaskIntoConstraints = false

  NSLayoutConstraint.activate([
    view.leadingAnchor.constraint(equalTo: containerController.view.leadingAnchor),
    view.trailingAnchor.constraint(equalTo: containerController.view.trailingAnchor),
    view.topAnchor.constraint(equalTo: containerController.view.topAnchor),
    view.bottomAnchor.constraint(equalTo: containerController.view.bottomAnchor)
  ])

  withLanguage(type.language) {
    let (parent, _) = traitControllers(
      device: type.device,
      orientation: type.orientation,
      child: containerController,
      additionalTraits: contentSizeTraits
    )

    containerController.overrideUserInterfaceStyle = type.style

    let targetSize: CGSize = {
      if let size = size {
        return size
      } else if useIntrinsicSize {
        containerController.view.setNeedsLayout()
        containerController.view.layoutIfNeeded()
        let fitting = containerController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if fitting.width > 0, fitting.height > 0 {
          return fitting
        }
      }
      return type.device.deviceSize(in: type.orientation)
    }()

    parent.view.frame.size = targetSize
    containerController.view.frame.size = targetSize

    if let testScheduler = AppEnvironment.current.scheduler as? TestScheduler {
      testScheduler.run()
    }

    let name = snapshotName(
      file: file,
      function: testName,
      type: type
    )

    let strategy: Snapshotting<UIView, UIImage> = {
      if let precision = perceptualPrecision {
        return .image(perceptualPrecision: precision)
      }
      return .image
    }()

    let directory = snapshotDirectory(for: file)

    if let failure = verifySnapshot(
      of: parent.view,
      as: strategy,
      named: name,
      record: record,
      snapshotDirectory: directory,
      file: file,
      testName: testName,
      line: line
    ) {
      XCTFail(
        """
        Snapshot failed for \(name)
        device=\(type.device.snapshotDescription),
        lang=\(type.language.rawValue),
        style=\(type.style.snapshotDescription),
        font=\(type.contentSizeCategory.snapshotDescription),
        orientation=\(type.orientation.snapshotDescription)
        \(failure)
        """,
        file: file,
        line: line
      )
    }
  }
}

// Configures environment, traits, style, font size, and naming before asserting a snapshot of a SwiftUI View.
internal func assertSnapshot<Content: View>(
  forSwiftUIView view: Content,
  withType type: ScreenshotType,
  size: CGSize? = nil,
  useIntrinsicSize: Bool = false,
  perceptualPrecision: Float? = nil,
  record: Bool = false,
  file: StaticString = #file,
  testName: String = #function,
  line: UInt = #line
) {
  let hosting = UIHostingController(rootView: view)

  let targetSize: CGSize = {
    if let size = size {
      return size
    } else if useIntrinsicSize {
      let proposed = type.device.deviceSize(in: type.orientation)
      let fitting = hosting.sizeThatFits(in: CGSize(width: proposed.width, height: .greatestFiniteMagnitude))
      if fitting.width > 0, fitting.height > 0 {
        return fitting
      }
    }
    return type.device.deviceSize(in: type.orientation)
  }()

  hosting.view.frame = CGRect(origin: .zero, size: targetSize)

  assertSnapshot(
    forController: hosting,
    withType: type,
    perceptualPrecision: perceptualPrecision,
    record: record,
    file: file,
    testName: testName,
    line: line
  )
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
  let styleComponent = sanitizeSnapshotComponent(type.style.snapshotDescription)
  let fontComponent = sanitizeSnapshotComponent(type.contentSizeCategory.snapshotDescription)
  let orientationComponent = sanitizeSnapshotComponent(type.orientation.snapshotDescription)
  return [
    deviceComponent,
    languageComponent,
    styleComponent,
    fontComponent,
    orientationComponent
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

private extension SnapshotDevice {
  var snapshotDescription: String {
    switch self {
    case .phone4inch: return "4in"
    case .phone4_7inch: return "4-7in"
    case .phone5_5inch: return "5-5in"
    case .phone5_8inch: return "5-8in"
    case .pad: return "pad"
    }
  }
}

private extension SnapshotOrientation {
  var snapshotDescription: String {
    switch self {
    case .portrait: return "pt"
    case .landscape: return "ls"
    }
  }
}

private extension UIUserInterfaceStyle {
  var snapshotDescription: String {
    switch self {
    case .light: return "lt"
    case .dark: return "dk"
    default: return "un"
    }
  }
}

private extension UIContentSizeCategory {
  var snapshotDescription: String {
    switch self {
    case .extraSmall: return "xs"
    case .small: return "s"
    case .medium: return "md"
    case .large: return "lg"
    case .extraLarge: return "xl"
    case .extraExtraLarge: return "xxl"
    case .extraExtraExtraLarge: return "xxxl"
    case .accessibilityMedium: return "aM"
    case .accessibilityLarge: return "aL"
    case .accessibilityExtraLarge: return "aXL"
    case .accessibilityExtraExtraLarge: return "aXXL"
    case .accessibilityExtraExtraExtraLarge: return "aXXXL"
    default: return self.rawValue
    }
  }
}

// Naming legend:
// device: phone4inch, phone4_7inch, phone5_5inch, phone5_8inch, pad
// lang:   language rawValue (en, es, fr, de, ja)
// style:  lt (light), dk (dark), un (unspecified)
// font:   xs, s, md, lg, xl, xxl, xxxl, aM, aL, aXL, aXXL, aXXXL
// orient: pt (portrait), ls (landscape)

private func snapshotDirectory(for file: StaticString) -> String {
  let fileURL = URL(fileURLWithPath: "\(file)")
  return fileURL.deletingLastPathComponent().appendingPathComponent("__Snapshots__").path
}

private func withLanguage(_ language: Language, body: () -> Void) {
  AppEnvironment.pushEnvironment(language: language)
  body()
  AppEnvironment.popEnvironment()
}
