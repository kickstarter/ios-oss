import KsApi
import ReactiveSwift
import Result
import UIKit

public protocol BackingCellViewModelInputs {
  func configureWith(backing: Backing, project: Project)
}
public protocol BackingCellViewModelOutputs {
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
    let backingAndProject = self.backingAndProjectProperty.signal.skipNil()
    let backing = backingAndProject.map { $0.0 }

    self.pledged = backingAndProject.map { backing, project in
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

    self.rootStackViewAlignment = backingAndProject
      .map { _, _ in AppEnvironment.current.isVoiceOverRunning() ? .fill : .leading }
  }

  fileprivate let backingAndProjectProperty = MutableProperty<(Backing, Project)?>(nil)
  public func configureWith(backing: Backing, project: Project) {
    self.backingAndProjectProperty.value = (backing, project)
  }

  public let pledged: Signal<String, NoError>
  public let reward: Signal<String, NoError>
  public let delivery: Signal<String, NoError>
  public let rootStackViewAlignment: Signal<UIStackViewAlignment, NoError>

  public var inputs: BackingCellViewModelInputs { return self }
  public var outputs: BackingCellViewModelOutputs { return self }
}
