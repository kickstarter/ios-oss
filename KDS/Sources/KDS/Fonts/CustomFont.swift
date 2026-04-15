import Foundation
import SwiftUI
import UIKit

public protocol CustomFont {
  var defaultSize: CGFloat { get }
  var textStyle: UIFont.TextStyle { get }
  func font(size: CGFloat?) -> UIFont
  func swiftUIFont(size: CGFloat?) -> Font
  func swiftUIFont(size: CGFloat?, dynamicTypeSize: DynamicTypeSize?) -> Font
}

public protocol CustomFontAccessible {
  static var fontFileURLs: [URL]? { get }
  static var isRegistered: Bool { get set }
  var fontName: String { get }
  var boldFontName: String { get }
}

extension UIFont {
  static func registerFontFromFileURL(_ fontURL: URL) throws {
    var cfError: Unmanaged<CFError>?
    let registered = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &cfError)

    if !registered, let error = cfError?.takeRetainedValue() as? Error {
      _ = error
    }
  }

  static func customFont(with fontConfig: CustomFont & CustomFontAccessible, size: CGFloat? = nil) -> UIFont {
    let fontName = UIAccessibility.isBoldTextEnabled ? fontConfig.boldFontName : fontConfig.fontName

    let fontConfigType = type(of: fontConfig)
    fontConfigType.registerFontIfUnregistered()

    guard let font = UIFont(name: fontName, size: size ?? fontConfig.defaultSize) else {
      assert(
        false,
        "Tried to loading custom font \(fontName) but was unable to. Using system default font, instead."
      )
      return self.defaultSystemFont(with: fontConfig, size: size)
    }

    let metrics = UIFontMetrics(forTextStyle: fontConfig.textStyle)
    let finalFont = metrics.scaledFont(for: font, compatibleWith: UITraitCollection.current)
    return finalFont
  }

  static func customFont(
    with fontConfig: CustomFont & CustomFontAccessible,
    size: CGFloat? = nil,
    dynamicTypeSize: DynamicTypeSize?
  ) -> UIFont {
    if let dynamicTypeSize = dynamicTypeSize {
      let category = dynamicTypeSize.toUIContentSizeCategory()
      let traits = UITraitCollection(preferredContentSizeCategory: category)
      return self.customFont(with: fontConfig, size: size, traitCollection: traits)
    } else {
      return self.customFont(with: fontConfig, size: size, traitCollection: .current)
    }
  }

  static func defaultSystemFont(
    with fontConfig: CustomFont,
    size: CGFloat? = nil
  ) -> UIFont {
    let font = UIFont.preferredFont(
      forTextStyle: fontConfig.textStyle,
      compatibleWith: .current
    )

    return UIFont(
      descriptor: font.fontDescriptor,
      size: ceil(font.pointSize / fontConfig.defaultSize * (size ?? fontConfig.defaultSize))
    )
  }
}

extension DynamicTypeSize {
  fileprivate func toUIContentSizeCategory() -> UIContentSizeCategory {
    switch self {
    case .xSmall: return .extraSmall
    case .small: return .small
    case .medium: return .medium
    case .large: return .large
    case .xLarge: return .extraLarge
    case .xxLarge: return .extraExtraLarge
    case .xxxLarge: return .extraExtraExtraLarge
    case .accessibility1: return .accessibilityMedium
    case .accessibility2: return .accessibilityLarge
    case .accessibility3: return .accessibilityExtraLarge
    case .accessibility4: return .accessibilityExtraExtraLarge
    case .accessibility5: return .accessibilityExtraExtraExtraLarge
    @unknown default:
      return .large
    }
  }
}

extension CustomFont {
  /// Converts the custom font to a SwiftUI `Font`.
  /// - Parameter size: The font size to apply. If `nil`, the default size for the font will be used.
  /// - Returns: A SwiftUI `Font` created from the custom `UIFont`.
  public func swiftUIFont(size: CGFloat? = nil) -> Font {
    return Font(self.font(size: size))
  }

  public func swiftUIFont(size: CGFloat? = nil, dynamicTypeSize: DynamicTypeSize? = nil) -> Font {
    // Build a UIFont using the provided dynamic type size when available.
    // We need `self` to conform to CustomFontAccessible to resolve font names; if not, fall back to system font.
    if let accessible = self as? (CustomFont & CustomFontAccessible) {
      let uiFont = UIFont.customFont(with: accessible, size: size, dynamicTypeSize: dynamicTypeSize)
      return Font(uiFont)
    } else {
      // Fallback: scale the system font for the given text style
      let traits: UITraitCollection
      if let dts = dynamicTypeSize {
        let category = dts.toUIContentSizeCategory()
        traits = UITraitCollection(preferredContentSizeCategory: category)
      } else {
        traits = .current
      }
      let uiFont = UIFont.defaultSystemFont(with: self, size: size, compatibleWith: traits)
      return Font(uiFont)
    }
  }
}

extension CustomFontAccessible {
  /// Registers the font files so that they're available for use in the process.
  /// - Throws: May throw an error from `kCTFontManagerErrorDomain` if registration fails.
  /// Note that calling this more than once will cause a thrown error.
  static func registerFont() throws {
    guard let fontFileURLs = self.fontFileURLs else {
      return
    }

    for fontFileURL in fontFileURLs {
      try UIFont.registerFontFromFileURL(fontFileURL)
    }
  }

  /// Registers the font if `self.isRegistered` is false.
  public static func registerFontIfUnregistered() {
    if self.isRegistered {
      return
    }

    do {
      try self.registerFont()
    } catch {
      assert(false, "Unable to register font: \(error)")
    }

    // We only want to attempt registration once; mark it as true whether it succeeded or failed.
    self.isRegistered = true
  }
}
