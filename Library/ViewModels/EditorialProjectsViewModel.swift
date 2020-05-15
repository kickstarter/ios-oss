import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol EditorialProjectsViewModelInputs {
  func closeButtonTapped()
  func configure(with tagId: DiscoveryParams.TagID)
  func discoveryPageViewControllerContentOffsetChanged(to offset: CGPoint)
  func viewDidLoad()
}

public protocol EditorialProjectsViewModelOutputs {
  var applyViewTransformsWithYOffset: Signal<CGFloat, Never> { get }
  var configureDiscoveryPageViewControllerWithParams: Signal<DiscoveryParams, Never> { get }
  var closeButtonImageTintColor: Signal<UIColor, Never> { get }
  var dismiss: Signal<(), Never> { get }
  var imageName: Signal<String, Never> { get }
  func preferredStatusBarStyle() -> UIStatusBarStyle
  var titleLabelText: Signal<String, Never> { get }
  var setNeedsStatusBarAppearanceUpdate: Signal<(), Never> { get }
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

    let configureWithParams: Signal<DiscoveryParams, Never> = tagId
      .map { tagId in DiscoveryParams.defaults |> DiscoveryParams.lens.tagId .~ tagId }

    self.configureDiscoveryPageViewControllerWithParams = configureWithParams
    self.imageName = tagId.map(editorialImageName)
    self.titleLabelText = tagId.map(editorialTitleLabelText)

    self.dismiss = self.closeButtonTappedProperty.signal

    let needsLightTreatment = self.discoveryPageViewControllerContentOffsetChangedProperty.signal
      .skipNil()
      .map { offset in offset.y < 0 }

    self.preferredStatusBarStyleProperty <~ needsLightTreatment
      .map { $0 ? .lightContent : .default }
      .skipRepeats()

    self.closeButtonImageTintColor = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(.white),
      needsLightTreatment.map { $0 ? .white : .ksr_soft_black }
    )
    .skipRepeats()

    self.setNeedsStatusBarAppearanceUpdate = self.preferredStatusBarStyleProperty.signal.ignoreValues()

    self.applyViewTransformsWithYOffset = self.discoveryPageViewControllerContentOffsetChangedProperty.signal
      .skipNil()
      .map(\.y)

    configureWithParams
      .observeValues { AppEnvironment.current.koala.trackCollectionViewed(params: $0) }
  }

  private let closeButtonTappedProperty = MutableProperty(())
  public func closeButtonTapped() {
    self.closeButtonTappedProperty.value = ()
  }

  private let configureWithTagIdProperty = MutableProperty<DiscoveryParams.TagID?>(nil)
  public func configure(with tagId: DiscoveryParams.TagID) {
    self.configureWithTagIdProperty.value = tagId
  }

  private let discoveryPageViewControllerContentOffsetChangedProperty = MutableProperty<CGPoint?>(nil)
  public func discoveryPageViewControllerContentOffsetChanged(to offset: CGPoint) {
    self.discoveryPageViewControllerContentOffsetChangedProperty.value = offset
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private var preferredStatusBarStyleProperty = MutableProperty<UIStatusBarStyle>(.lightContent)
  public func preferredStatusBarStyle() -> UIStatusBarStyle {
    return self.preferredStatusBarStyleProperty.value
  }

  public let applyViewTransformsWithYOffset: Signal<CGFloat, Never>
  public let configureDiscoveryPageViewControllerWithParams: Signal<DiscoveryParams, Never>
  public let closeButtonImageTintColor: Signal<UIColor, Never>
  public let dismiss: Signal<(), Never>
  public let imageName: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>
  public let setNeedsStatusBarAppearanceUpdate: Signal<(), Never>

  public var inputs: EditorialProjectsViewModelInputs { return self }
  public var outputs: EditorialProjectsViewModelOutputs { return self }
}

private func editorialImageName(for tagId: DiscoveryParams.TagID) -> String {
  switch tagId {
  case .lightsOn:
    return "lights-on"
  }
}

private func editorialTitleLabelText(for tagId: DiscoveryParams.TagID) -> String {
  switch tagId {
  case .lightsOn: return Strings.Show_up_for_the_spaces_you_love()
  }
}
