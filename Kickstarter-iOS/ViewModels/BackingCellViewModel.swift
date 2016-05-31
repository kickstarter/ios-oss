import Library
import Models
import ReactiveCocoa
import Result

internal protocol BackingCellViewModelInputs {
  func configureWith(backing backing: Backing, project: Project)
}

internal protocol BackingCellViewModelOutputs {
  var pledged: Signal<String, NoError> { get }
  var reward: Signal<String, NoError> { get }
  var delivery: Signal<String, NoError> { get }
}

internal protocol BackingCellViewModelType {
  var inputs: BackingCellViewModelInputs { get }
  var outputs: BackingCellViewModelOutputs { get }
}

internal final class BackingCellViewModel: BackingCellViewModelType, BackingCellViewModelInputs,
BackingCellViewModelOutputs {

  internal init() {
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
  internal func configureWith(backing backing: Backing, project: Project) {
    self.backingAndProjectProperty.value = (backing, project)
  }

  internal let pledged: Signal<String, NoError>
  internal let reward: Signal<String, NoError>
  internal let delivery: Signal<String, NoError>

  internal var inputs: BackingCellViewModelInputs { return self }
  internal var outputs: BackingCellViewModelOutputs { return self }
}
