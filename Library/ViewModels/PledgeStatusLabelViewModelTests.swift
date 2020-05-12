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
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.canceled,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "The creator canceled this project, so your payment method was never charged."
    ])
  }

  func testProjectStatusFailed_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.failed,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "This project didn’t reach its funding goal, so your payment method was never charged."
    ])
  }

  func testBackingStatus_Canceled_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.live,
      backingState: BackingState.canceled
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "You canceled your pledge for this project."
    ])
  }

  func testBackingStatus_Collected_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.collected
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We collected your pledge for this project."
    ])
  }

  func testBackingStatus_Dropped_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.dropped
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "Your pledge was dropped because of payment errors."
    ])
  }

  func testBackingStatus_Errored_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.errored
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We can’t process your pledge. Please update your payment method."
    ])
  }

  func testBackingStatus_Preauth_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.live,
      backingState: BackingState.preauth
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We're processing your pledge—pull to refresh."
    ])
  }

  func testBackingStatus_Pledged_Backer() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: false,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "If the project reaches its funding goal, you will be charged on October 16, 2016."
    ])
  }

  func testBackingStatus_Pledged_OtherCurrency_Backer() {
    withEnvironment(locale: Locale(identifier: "en")) {
      let data = PledgeStatusLabelViewData(
        currentUserIsCreatorOfProject: false,
        needsConversion: true,
        pledgeAmount: 10,
        projectCountry: Project.Country.hk,
        projectDeadline: 1_476_657_315,
        projectState: ProjectState.successful,
        backingState: BackingState.pledged
      )

      self.vm.inputs.configure(with: data)

      self.labelTextString.assertValues([
        "If the project reaches its funding goal, you will be charged HK$ 10 on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_AllOtherStatuses_Backer() {
    let statuses = BackingState.allCases
      .filter { ![.canceled, .collected, .dropped, .errored, .pledged, .preauth].contains($0) }

    statuses.forEach { backingState in
      let data = PledgeStatusLabelViewData(
        currentUserIsCreatorOfProject: false,
        needsConversion: false,
        pledgeAmount: 10,
        projectCountry: Project.Country.hk,
        projectDeadline: 1_476_657_315,
        projectState: ProjectState.successful,
        backingState: backingState
      )

      self.vm.inputs.configure(with: data)
    }

    self.labelTextString.assertValues([])
  }

  func testProjectStatusCanceled_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.canceled,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "You canceled this project, so the backer’s payment method was never charged."
    ])
  }

  func testProjectStatusFailed_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.failed,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "Your project didn’t reach its funding goal, so the backer’s payment method was never charged."
    ])
  }

  func testBackingStatus_Canceled_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.live,
      backingState: BackingState.canceled
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "The backer canceled their pledge for this project."
    ])
  }

  func testBackingStatus_Collected_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.collected
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We collected the backer’s pledge for this project."
    ])
  }

  func testBackingStatus_Dropped_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.dropped
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "This pledge was dropped because of payment errors."
    ])
  }

  func testBackingStatus_Errored_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.errored
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We can’t process this pledge because of a problem with the backer’s payment method."
    ])
  }

  func testBackingStatus_Pledged_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.live,
      backingState: BackingState.pledged
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "If your project reaches its funding goal, the backer will be charged on October 16, 2016."
    ])
  }

  func testBackingStatus_Pledged_OtherCurrency_Creator() {
    withEnvironment(locale: Locale(identifier: "en")) {
      let data = PledgeStatusLabelViewData(
        currentUserIsCreatorOfProject: true,
        needsConversion: true,
        pledgeAmount: 10,
        projectCountry: Project.Country.hk,
        projectDeadline: 1_476_657_315,
        projectState: ProjectState.successful,
        backingState: BackingState.pledged
      )

      self.vm.inputs.configure(with: data)

      self.labelTextString.assertValues([
        "If your project reaches its funding goal, the backer will be charged HK$ 10 on October 16, 2016."
      ])
    }
  }

  func testBackingStatus_Preauth_Creator() {
    let data = PledgeStatusLabelViewData(
      currentUserIsCreatorOfProject: true,
      needsConversion: false,
      pledgeAmount: 10,
      projectCountry: Project.Country.hk,
      projectDeadline: 1_476_657_315,
      projectState: ProjectState.successful,
      backingState: BackingState.preauth
    )

    self.vm.inputs.configure(with: data)

    self.labelTextString.assertValues([
      "We're processing this pledge—pull to refresh."
    ])
  }

  func testBackingStatus_AllOtherStatuses_Creator() {
    let statuses = BackingState.allCases
      .filter { ![.canceled, .collected, .dropped, .errored, .pledged, .preauth].contains($0) }

    statuses.forEach { backingState in
      let data = PledgeStatusLabelViewData(
        currentUserIsCreatorOfProject: true,
        needsConversion: false,
        pledgeAmount: 10,
        projectCountry: Project.Country.hk,
        projectDeadline: 1_476_657_315,
        projectState: ProjectState.successful,
        backingState: backingState
      )

      self.vm.inputs.configure(with: data)
    }

    self.labelTextString.assertValues([])
  }
}
