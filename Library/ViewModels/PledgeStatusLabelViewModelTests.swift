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

  func testProjectStatusCanceled() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .canceled

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "The creator canceled this project, so your payment method was never charged."
      ])
    }
  }

  func testProjectStatusFailed() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .failed

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "This project didn’t reach its funding goal, so your payment method was never charged."
      ])
    }
  }

  func testProjectStatus_AllOtherStatuses() {
    withEnvironment(currentUser: .template) {
      let statuses = Project.State.allCases
        .filter { ![.canceled, .failed].contains($0) }

      statuses.forEach {
        let creator = User.template
          |> User.lens.id .~ 5

        let project = Project.cosmicSurgery
          |> Project.lens.creator .~ creator
          |> Project.lens.state .~ $0
          |> Project.lens.personalization.backing .~ nil

        self.vm.inputs.configure(with: project)
      }

      self.labelTextString.assertValues([])
    }
  }

  func testBackingStatus_Canceled() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .canceled
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "You canceled your pledge for this project."
      ])
    }
  }

  func testBackingStatus_Collected() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .collected
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "We collected your pledge for this project."
      ])
    }
  }

  func testBackingStatus_Dropped() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .dropped
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "Your pledge was dropped because of payment errors."
      ])
    }
  }

  func testBackingStatus_Errored() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .errored
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "We can’t process your pledge. Please update your payment method."
      ])
    }
  }

  func testBackingStatus_Pledged() {
    withEnvironment(currentUser: .template) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.state .~ .successful
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.USD.rawValue
        |> Project.lens.country .~ .us
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .pledged
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "If the project reaches its funding goal, you will be charged on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_Pledged_OtherCurrency() {
    withEnvironment(currentUser: .template, locale: Locale(identifier: "en")) {
      let creator = User.template
        |> User.lens.id .~ 5

      let project = Project.cosmicSurgery
        |> Project.lens.creator .~ creator
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.HKD.rawValue
        |> Project.lens.country .~ .hk
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.backing .~ (
          Backing.template
            |> Backing.lens.status .~ .pledged
        )

      self.vm.inputs.configure(with: project)

      self.labelTextString.assertValues([
        "If the project reaches its funding goal, you will be charged HK$ 10 on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_AllOtherStatuses() {
    withEnvironment(currentUser: .template) {
      let statuses = Backing.Status.allCases
        .filter { ![.canceled, .collected, .dropped, .errored, .pledged].contains($0) }

      statuses.forEach {
        let creator = User.template
          |> User.lens.id .~ 5

        let project = Project.cosmicSurgery
          |> Project.lens.creator .~ creator
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
