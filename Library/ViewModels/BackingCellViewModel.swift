import KsApi
import ReactiveSwift
import UIKit

public protocol BackingCellViewModelInputs {
  func configureWith(backing: Backing, project: Project, isFromBacking: Bool)
}

public protocol BackingCellViewModelOutputs {
  /// Emits a boolean whether the backing info button is hidden or not.
  var backingInfoButtonIsHidden: Signal<Bool, Never> { get }

  var pledged: Signal<String, Never> { get }
  var reward: Signal<String, Never> { get }
  var delivery: Signal<String, Never> { get }
  var rootStackViewAlignment: Signal<UIStackView.Alignment, Never> { get }
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
        backing_amount: Format.currency(backing.amount, country: project.country)
      )
    }

    self.reward = backing.map { $0.reward?.description ?? "" }

    self.delivery = backing.map { backing in
      backing.reward?.estimatedDeliveryOn.map {
        Strings.backing_info_estimated_delivery_date(
          delivery_date: Format.date(
            secondsInUTC: $0,
            template: DateFormatter.monthYear,
            timeZone: UTCTimeZone
          )
        )
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

  public let backingInfoButtonIsHidden: Signal<Bool, Never>
  public let pledged: Signal<String, Never>
  public let reward: Signal<String, Never>
  public let delivery: Signal<String, Never>
  public let rootStackViewAlignment: Signal<UIStackView.Alignment, Never>

  public var inputs: BackingCellViewModelInputs { return self }
  public var outputs: BackingCellViewModelOutputs { return self }
}
