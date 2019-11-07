import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import XCTest

final class PledgeStatusLabelViewModelTests: TestCase {
  private let vm: PledgeStatusLabelViewModelType = PledgeStatusLabelViewModel()

  private let labelTextString = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.labelText.map { $0.string }.observe(self.labelTextString.observer)
  }

  func testProjectStatusCanceled_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .canceled

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "The creator canceled this project, so your payment method was never charged."
      ])
    }
  }

  func testProjectStatusFailed_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .failed

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "This project didn’t reach its funding goal, so your payment method was never charged."
      ])
    }
  }

  func testProjectStatus_AllOtherStatuses_Backer() {
    withEnvironment(currentUser: .template) {
      self.vm.inputs.viewDidLoad()

      let statuses = Project.State.allCases
        .filter { ![.canceled, .failed].contains($0) }

      statuses.forEach {
        let project = Project.template
          |> Project.lens.state .~ $0
          |> Project.lens.personalization.backing .~ nil

        self.vm.inputs.configure(with: project)
      }

      self.labelTextString.assertValues([])
    }
  }

  func testBackingStatus_Canceled_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .canceled
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "You canceled your pledge for this project."
      ])
    }
  }

  func testBackingStatus_Collected_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .collected
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "We collected your pledge for this project."
      ])
    }
  }

  func testBackingStatus_Dropped_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .dropped
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "Your pledge was dropped because of payment errors."
      ])
    }
  }

  func testBackingStatus_Errored_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .errored
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        // TODO: should emit
      ])
    }
  }

  func testBackingStatus_Pledged_Backer() {
    withEnvironment(currentUser: .template) {
      let project = Project.template
        |> Project.lens.state .~ .successful
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.USD.rawValue
        |> Project.lens.country .~ .us
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .pledged
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "If the project reaches its funding goal, you will be charged on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_Pledged_OtherCurrency_Backer() {
    withEnvironment(currentUser: .template, locale: Locale(identifier: "en")) {
      let project = Project.template
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.HKD.rawValue
        |> Project.lens.country .~ .hk
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .pledged
        )

      self.vm.inputs.configure(with: project)
      self.vm.inputs.viewDidLoad()

      self.labelTextString.assertValues([
        "If the project reaches its funding goal, you will be charged HK$ 10 on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_AllOtherStatuses_Backer() {
    withEnvironment(currentUser: .template) {
      let statuses = Backing.Status.allCases
        .filter { ![.canceled, .collected, .dropped, .errored, .pledged].contains($0) }

      statuses.forEach {
        let project = Project.template
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.backing .~ (
            Backing.template
              |> Backing.lens.status .~ $0
          )

        self.vm.inputs.configure(with: project)
      }

      self.labelTextString.assertValues([])
    }
  }
}
