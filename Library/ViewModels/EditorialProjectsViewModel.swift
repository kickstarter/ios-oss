import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol EditorialProjectViewModelInputs {
  func closeButtonTapped()
  func configure(with tagId: DiscoveryParams.TagID)
  func viewDidLoad()
}

public protocol EditorialProjectViewModelOutputs {
  var configureDiscoveryPageViewControllerWithParams: Signal<DiscoveryParams, Never> { get }
  var dismiss: Signal<(), Never> { get }
}

public protocol EditorialProjectViewModelType {
  var inputs: EditorialProjectViewModelInputs { get }
  var outputs: EditorialProjectViewModelOutputs { get }
}

public class EditorialProjectViewModel: EditorialProjectViewModelType,
  EditorialProjectViewModelInputs, EditorialProjectViewModelOutputs {
  public init() {
    let tagId = Signal.combineLatest(
      self.configureWithTagIdProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.configureDiscoveryPageViewControllerWithParams = tagId
      .map { tagId in DiscoveryParams.defaults |> DiscoveryParams.lens.tagId .~ tagId }

    self.dismiss = self.closeButtonTappedProperty.signal
  }

  private let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let configureWithTagIdProperty = MutableProperty<DiscoveryParams.TagID?>(nil)
  public func configure(with tagId: DiscoveryParams.TagID) {
    self.configureWithTagIdProperty.value = tagId
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let configureDiscoveryPageViewControllerWithParams: Signal<DiscoveryParams, Never>
  public let dismiss: Signal<(), Never>

  public var inputs: EditorialProjectViewModelInputs { return self }
  public var outputs: EditorialProjectViewModelOutputs { return self }
}
