import KsApi
import Prelude
import ReactiveSwift

public protocol ExternalSourceViewElementCellViewModelInputs {
  /// Call to configure with a `ExternalSourceViewElement` representing external source element.
  func configureWith(element: ExternalSourceViewElement)
}

public protocol ExternalSourceViewElementCellViewModelOutputs {
  /// Emits a text `String` representing the iframe tag's src attibute captured in the html parser.
  var htmlText: Signal<String, Never> { get }

  /// Emits an optional `Int` taken from iframe representing that embedded content's height in a webview.
  var contentHeight: Signal<Int, Never> { get }
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
  }

  fileprivate let externalSourceViewElement =
    MutableProperty<ExternalSourceViewElement?>(nil)
  public func configureWith(element: ExternalSourceViewElement) {
    self.externalSourceViewElement.value = element
  }

  public let contentHeight: Signal<Int, Never>
  public let htmlText: Signal<String, Never>

  public var inputs: ExternalSourceViewElementCellViewModelInputs { self }
  public var outputs: ExternalSourceViewElementCellViewModelOutputs { self }
}
