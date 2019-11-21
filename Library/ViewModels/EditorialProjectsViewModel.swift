import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol EditorialProjectsViewModelInputs {
  func closeButtonTapped()
  func configure(with tagId: DiscoveryParams.TagID)
  func viewDidLoad()
}

public protocol EditorialProjectsViewModelOutputs {
  var configureDiscoveryPageViewControllerWithParams: Signal<DiscoveryParams, Never> { get }
  var dismiss: Signal<(), Never> { get }
}

public protocol EditorialProjectsViewModelType {
  var inputs: EditorialProjectsViewModelInputs { get }
  var outputs: EditorialProjectsViewModelOutputs { get }
}

public class EditorialProjectsViewModel: EditorialProjectsViewModelType,
  EditorialProjectsViewModelInputs, EditorialProjectsViewModelOutputs {
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

  public var inputs: EditorialProjectsViewModelInputs { return self }
  public var outputs: EditorialProjectsViewModelOutputs { return self }
}
