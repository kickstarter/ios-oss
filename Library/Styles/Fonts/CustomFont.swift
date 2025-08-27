import Foundation
import SwiftUI
import UIKit

public protocol CustomFont {
  var defaultSize: CGFloat { get }
  var textStyle: UIFont.TextStyle { get }
  func font(size: CGFloat?) -> UIFont
  func swiftUIFont(size: CGFloat?) -> Font
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
      throw error
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

extension CustomFont {
  /// Converts the custom font to a SwiftUI `Font`.
  /// - Parameter size: The font size to apply. If `nil`, the default size for the font will be used.
  /// - Returns: A SwiftUI `Font` created from the custom `UIFont`.
  public func swiftUIFont(size: CGFloat? = nil) -> Font {
    return Font(self.font(size: size))
  }
}

extension CustomFontAccessible {
  /// Registers the font files so that they're available for use in the process.
  /// - Returns: `true` if the font has been successfully registered and is ready for use; `false` if a backup font should be used.
  static func registerFont() throws {
    guard let fontFileURLs = self.fontFileURLs else {
      return
    }

    for fontFileURL in fontFileURLs {
      try UIFont.registerFontFromFileURL(fontFileURL)
    }
  }

  /// Registers the font if `self.isRegistered` is false.
  /// - Returns: `true` if the font has been successfully registered and is ready for use; `false` if a backup font should be used.
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
