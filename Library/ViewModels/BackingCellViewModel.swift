import KsApi
import ReactiveSwift
import Result

public protocol BackingCellViewModelInputs {
  func configureWith(backing: Backing, project: Project, isFromBacking: Bool)
}
public protocol BackingCellViewModelOutputs {
  /// Emits a boolean whether the backing info button is hidden or not.
  var backingInfoButtonIsHidden: Signal<Bool, NoError> { get }

  var pledged: Signal<String, NoError> { get }
  var reward: Signal<String, NoError> { get }
  var delivery: Signal<String, NoError> { get }
  var rootStackViewAlignment: Signal<UIStackViewAlignment, NoError> { get }
}

public protocol BackingCellViewModelType {
  var inputs: BackingCellViewModelInputs { get }
  var outputs: BackingCellViewModelOutputs { get }
}

public final class BackingCellViewModel: BackingCellViewModelType, BackingCellViewModelInputs,
BackingCellViewModelOutputs {

  public init() {
    let backingAndProjectAndIsFromBacking = self.backingAndProjectAndIsFromBackingProperty.signal.skipNil()
    let backing = backingAndProjectAndIsFromBacking.map { $0.0 }

    self.backingInfoButtonIsHidden = backingAndProjectAndIsFromBacking
      .map { _, _, isFromBacking in isFromBacking }

    self.pledged = backingAndProjectAndIsFromBacking.map { backing, project, _ in
        Strings.backing_info_pledged_backing_amount(
            backing_amount: Format.currency(backing.amount, country: project.country))
    }

    self.reward = backing.map { $0.reward?.description ?? "" }

    self.delivery = backing.map { backing in
      backing.reward?.estimatedDeliveryOn.map {
        Strings.backing_info_estimated_delivery_date(
          delivery_date:  Format.date(secondsInUTC: $0, dateFormat: "MMMM yyyy", timeZone: UTCTimeZone))
      }
    }
    .map { $0 ?? "" }

    self.rootStackViewAlignment = backingAndProjectAndIsFromBacking
      .map { _, _, _ in AppEnvironment.current.isVoiceOverRunning() ? .fill : .leading }
  }

  fileprivate let backingAndProjectAndIsFromBackingProperty = MutableProperty<(Backing, Project, Bool)?>(nil)
  public func configureWith(backing: Backing, project: Project, isFromBacking: Bool) {
    self.backingAndProjectAndIsFromBackingProperty.value = (backing, project, isFromBacking)
  }

  public let backingInfoButtonIsHidden: Signal<Bool, NoError>
  public let pledged: Signal<String, NoError>
  public let reward: Signal<String, NoError>
  public let delivery: Signal<String, NoError>
  public let rootStackViewAlignment: Signal<UIStackViewAlignment, NoError>

  public var inputs: BackingCellViewModelInputs { return self }
  public var outputs: BackingCellViewModelOutputs { return self }
}
