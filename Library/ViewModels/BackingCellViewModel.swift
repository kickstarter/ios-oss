import KsApi
import ReactiveCocoa
import Result

public protocol BackingCellViewModelInputs {
  func configureWith(backing backing: Backing, project: Project)
}

public protocol BackingCellViewModelOutputs {
  var pledged: Signal<String, NoError> { get }
  var reward: Signal<String, NoError> { get }
  var delivery: Signal<String, NoError> { get }
}

public protocol BackingCellViewModelType {
  var inputs: BackingCellViewModelInputs { get }
  var outputs: BackingCellViewModelOutputs { get }
}

public final class BackingCellViewModel: BackingCellViewModelType, BackingCellViewModelInputs,
BackingCellViewModelOutputs {

  public init() {
    let backingAndProject = self.backingAndProjectProperty.signal.ignoreNil()
    let backing = backingAndProject.map { $0.0 }

    self.pledged = backingAndProject.map { backing, project in
      localizedString(
        key: "backing_info.pledged",
        defaultValue: "Pledged: %{backing_amount}",
        substitutions: [
          "backing_amount": Format.currency(backing.amount, country: project.country)
        ])
    }

    self.reward = backing.map { $0.reward?.description ?? "" }

    self.delivery = backing.map { backing in
      backing.reward?.estimatedDeliveryOn.map {
        localizedString(
          key: "backing_info.estimated_delivery_date",
          defaultValue: "Estimated delivery %{delivery_date}",
          substitutions: [
            "delivery_date": Format.date(secondsInUTC: $0, dateStyle: .ShortStyle, timeStyle: .NoStyle)
          ]
        )
      }
    }
    .map { $0 ?? "" }
  }

  private let backingAndProjectProperty = MutableProperty<(Backing, Project)?>(nil)
  public func configureWith(backing backing: Backing, project: Project) {
    self.backingAndProjectProperty.value = (backing, project)
  }

  public let pledged: Signal<String, NoError>
  public let reward: Signal<String, NoError>
  public let delivery: Signal<String, NoError>

  public var inputs: BackingCellViewModelInputs { return self }
  public var outputs: BackingCellViewModelOutputs { return self }
}
