import Foundation

// Represents iFrame HTML, loaded on webview...
public struct ExternalSourceViewElement: HTMLViewElement {
  public let embeddedURLString: String
  public let embeddedURLContentHeight: Int?
}
