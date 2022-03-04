import KsApi
import Prelude
import ReactiveSwift

public protocol ExternalSourceViewElementCellViewModelInputs {
  /// Call to configure with a `ExternalSourceViewElement` representing external source element.
  func configureWith(element: ExternalSourceViewElement)

  /// Call to configure with a `WKWebView` with a blank html source string.
  func resetWebView()

  /// Call to configure with cell with its' contents' height.
  func toggleContentHeight(_ flag: Bool)
}

public protocol ExternalSourceViewElementCellViewModelOutputs {
  /// Emits a text `String` representing the iframe tag's src attibute captured in the html parser.
  var htmlText: Signal<String, Never> { get }

  /// Emits an optional `Int` taken from iframe representing that embedded content's height in a webview.
  var contentHeight: Signal<Int, Never> { get }

  /// Emits a signal to reset the `WKWebView`'s HTML content
  var resetWebViewContent: Signal<String, Never> { get }

  /// Emits a `Bool` to render the cells' height based on it's content size height.
  var toggleContentHeight: Signal<Bool, Never> { get }
}

public protocol ExternalSourceViewElementCellViewModelType {
  var inputs: ExternalSourceViewElementCellViewModelInputs { get }
  var outputs: ExternalSourceViewElementCellViewModelOutputs { get }
}

public final class ExternalSourceViewElementCellViewModel:
  ExternalSourceViewElementCellViewModelType, ExternalSourceViewElementCellViewModelInputs,
  ExternalSourceViewElementCellViewModelOutputs {
  // MARK: Initializers

  public init() {
    self.htmlText = self.externalSourceViewElement.signal.skipNil()
      .switchMap { element -> SignalProducer<String?, Never> in
        guard !element.embeddedURLString.isEmpty else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: element.embeddedURLString)
      }
      .skipNil()

    self.contentHeight = self.externalSourceViewElement.signal.skipNil()
      .switchMap { element -> SignalProducer<Int?, Never> in
        guard let contentHeight = element.embeddedURLContentHeight,
          !element.embeddedURLString.isEmpty else {
          return SignalProducer(value: nil)
        }

        return SignalProducer(value: contentHeight)
      }
      .skipNil()

    self.resetWebViewContent = self.resetWebViewContentProperty.signal.skipNil()
    self.toggleContentHeight = self.toggleContentProperty.signal
  }

  fileprivate let externalSourceViewElement =
    MutableProperty<ExternalSourceViewElement?>(nil)
  public func configureWith(element: ExternalSourceViewElement) {
    self.externalSourceViewElement.value = element
  }

  fileprivate let resetWebViewContentProperty =
    MutableProperty<String?>(nil)
  public func resetWebView() {
    self.resetWebViewContentProperty.value = "about:blank"
  }

  fileprivate let toggleContentProperty =
    MutableProperty<Bool>(false)
  public func toggleContentHeight(_ flag: Bool) {
    self.toggleContentProperty.value = flag
  }

  public let contentHeight: Signal<Int, Never>
  public let htmlText: Signal<String, Never>
  public let resetWebViewContent: Signal<String, Never>
  public let toggleContentHeight: Signal<Bool, Never>

  public var inputs: ExternalSourceViewElementCellViewModelInputs { self }
  public var outputs: ExternalSourceViewElementCellViewModelOutputs { self }
}
