import Foundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

final class CancelPledgeViewModelTests: TestCase {
  private let vm: CancelPledgeViewModelType = CancelPledgeViewModel()

  private let cancellationDetailsAttributedTextString = TestObserver<String, Never>()
  private let cancellationDetailsAttributedTextAttributedString = TestObserver<NSAttributedString, Never>()
  private let cancelPledgeButtonEnabled = TestObserver<Bool, Never>()
  private let cancelPledgeError = TestObserver<String, Never>()
  private let dismissKeyboard = TestObserver<Void, Never>()
  private let notifyDelegateCancelPledgeSuccess = TestObserver<String, Never>()
  private let popCancelPledgeViewController = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cancellationDetailsAttributedText
      .observe(self.cancellationDetailsAttributedTextAttributedString.observer)
    self.vm.outputs.cancellationDetailsAttributedText.map { $0.string }
      .observe(self.cancellationDetailsAttributedTextString.observer)
    self.vm.outputs.cancelPledgeButtonEnabled.observe(self.cancelPledgeButtonEnabled.observer)
    self.vm.outputs.cancelPledgeError.observe(self.cancelPledgeError.observer)
    self.vm.outputs.dismissKeyboard.observe(self.dismissKeyboard.observer)
    self.vm.outputs.notifyDelegateCancelPledgeSuccess.observe(self.notifyDelegateCancelPledgeSuccess.observer)
    self.vm.outputs.popCancelPledgeViewController.observe(self.popCancelPledgeViewController.observer)
  }

  func testConfigureCancelPledgeView() {
    let project = Project.cosmicSurgery
      |> Project.lens.country .~ Project.Country.us

    let data = CancelPledgeViewData(
      project: project,
      projectCountry: project.country,
      projectName: project.name,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
      backingId: "backing-id",
      pledgeAmount: 5
    )

    self.vm.inputs.configure(with: data)
    self.vm.inputs.viewDidLoad()

    let cancellationString = "Are you sure you wish to cancel your $5 pledge to Cosmic Surgery?"
    var pledgeAmountRange: NSRange = (cancellationString as NSString).range(of: "$5")
    var projectNameRange: NSRange = (cancellationString as NSString).range(of: "Cosmic Surgery")

    let boldFontAttribute = UIFont.ksr_callout().bolded

    self.cancellationDetailsAttributedTextString
      .assertValues([cancellationString])

    XCTAssertEqual(
      self.cancellationDetailsAttributedTextAttributedString.values
        .compactMap { $0.attribute(
          .font,
          at: pledgeAmountRange.location,
          effectiveRange: &pledgeAmountRange
        ) } as? [UIFont],
      [boldFontAttribute]
    )
    XCTAssertEqual(
      self.cancellationDetailsAttributedTextAttributedString.values
        .compactMap { $0.attribute(
          .font,
          at: projectNameRange.location,
          effectiveRange: &projectNameRange
        ) } as? [UIFont],
      [boldFontAttribute]
    )

    self.vm.inputs.traitCollectionDidChange()

    self.cancellationDetailsAttributedTextString
      .assertValues([
        cancellationString,
        cancellationString
      ])
    XCTAssertEqual(
      self.cancellationDetailsAttributedTextAttributedString.values
        .compactMap { $0.attribute(
          .font,
          at: pledgeAmountRange.location,
          effectiveRange: &pledgeAmountRange
        ) } as? [UIFont],
      [boldFontAttribute, boldFontAttribute]
    )
    XCTAssertEqual(
      self.cancellationDetailsAttributedTextAttributedString.values
        .compactMap { $0.attribute(
          .font,
          at: projectNameRange.location,
          effectiveRange: &projectNameRange
        ) } as? [UIFont],
      [boldFontAttribute, boldFontAttribute]
    )
  }

  func testGoBackButtonTapped() {
    let project = Project.template

    let data = CancelPledgeViewData(
      project: project,
      projectCountry: project.country,
      projectName: project.name,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
      backingId: "backing-id",
      pledgeAmount: 5
    )

    self.vm.inputs.configure(with: data)

    self.vm.inputs.viewDidLoad()

    self.popCancelPledgeViewController.assertDidNotEmitValue()

    self.vm.inputs.goBackButtonTapped()

    self.popCancelPledgeViewController.assertValueCount(1)
  }

  func testDismissKeyboard() {
    let project = Project.template

    let data = CancelPledgeViewData(
      project: project,
      projectCountry: project.country,
      projectName: project.name,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
      backingId: "backing-id",
      pledgeAmount: 5
    )

    self.vm.inputs.configure(with: data)

    self.vm.inputs.viewDidLoad()

    self.dismissKeyboard.assertDidNotEmitValue()

    self.vm.inputs.textFieldShouldReturn()

    self.dismissKeyboard.assertValueCount(1)
  }

  func testViewTapped() {
    let project = Project.template

    let data = CancelPledgeViewData(
      project: project,
      projectCountry: project.country,
      projectName: project.name,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
      backingId: "backing-id",
      pledgeAmount: 5
    )

    self.vm.inputs.configure(with: data)

    self.vm.inputs.viewDidLoad()

    self.dismissKeyboard.assertDidNotEmitValue()

    self.vm.inputs.viewTapped()

    self.dismissKeyboard.assertValueCount(1)
  }

  func testCancelPledgeButtonEnabled() {
    let envelope = GraphMutationEmptyResponseEnvelope()
    let mockService = MockService(cancelBackingResult: .success(envelope))

    withEnvironment(apiService: mockService) {
      let project = Project.template

      let data = CancelPledgeViewData(
        project: project,
        projectCountry: project.country,
        projectName: project.name,
        omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
        backingId: String(project.personalization.backing?.id ?? 0),
        pledgeAmount: project.personalization.backing?.pledgeAmount ?? 0
      )

      self.vm.inputs.configure(with: data)

      self.vm.inputs.viewDidLoad()

      self.cancelPledgeButtonEnabled.assertValues([true])

      self.vm.inputs.textFieldDidEndEditing(with: "cancel reason")

      self.cancelPledgeButtonEnabled.assertValues([true])

      self.vm.inputs.cancelPledgeButtonTapped()

      self.cancelPledgeButtonEnabled.assertValues(
        [true, false],
        "Cancel button disabled when request in flight"
      )

      self.scheduler.run()

      self.cancelPledgeButtonEnabled.assertValues(
        [true, false, true],
        "Cancel button enabled when request completes"
      )
    }
  }

  func testCancelPledge_Success() {
    let envelope = GraphMutationEmptyResponseEnvelope()
    let mockService = MockService(cancelBackingResult: .success(envelope))

    withEnvironment(apiService: mockService) {
      let project = Project.template

      let data = CancelPledgeViewData(
        project: project,
        projectCountry: project.country,
        projectName: project.name,
        omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
        backingId: String(project.personalization.backing?.id ?? 0),
        pledgeAmount: project.personalization.backing?.pledgeAmount ?? 0
      )

      self.vm.inputs.configure(with: data)

      self.vm.inputs.viewDidLoad()

      self.notifyDelegateCancelPledgeSuccess.assertDidNotEmitValue()
      self.cancelPledgeError.assertDidNotEmitValue()

      self.vm.inputs.cancelPledgeButtonTapped()

      self.notifyDelegateCancelPledgeSuccess.assertDidNotEmitValue()
      self.cancelPledgeError.assertDidNotEmitValue()

      self.scheduler.run()

      self.notifyDelegateCancelPledgeSuccess.assertValues(["You\'ve canceled your pledge."])
      self.cancelPledgeError.assertDidNotEmitValue()

      self.vm.inputs.textFieldDidEndEditing(with: "No money")

      self.vm.inputs.cancelPledgeButtonTapped()

      self.notifyDelegateCancelPledgeSuccess.assertValueCount(1)
      self.cancelPledgeError.assertDidNotEmitValue()

      self.scheduler.run()

      self.notifyDelegateCancelPledgeSuccess.assertValues([
        "You\'ve canceled your pledge.",
        "You\'ve canceled your pledge."
      ])
      self.cancelPledgeError.assertDidNotEmitValue()
    }
  }

  func testCancelPledge_Error() {
    let mockService = MockService(
      cancelBackingResult:
      .failure(
        .decodeError(
          .init(message: "You can't cancel your pledge right now.")
        )
      )
    )

    withEnvironment(apiService: mockService) {
      let project = Project.template

      let data = CancelPledgeViewData(
        project: project,
        projectCountry: project.country,
        projectName: project.name,
        omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
        backingId: String(project.personalization.backing?.id ?? 0),
        pledgeAmount: project.personalization.backing?.pledgeAmount ?? 0
      )

      self.vm.inputs.configure(with: data)

      self.vm.inputs.viewDidLoad()

      self.notifyDelegateCancelPledgeSuccess.assertDidNotEmitValue()
      self.cancelPledgeError.assertDidNotEmitValue()

      self.vm.inputs.cancelPledgeButtonTapped()

      self.notifyDelegateCancelPledgeSuccess.assertDidNotEmitValue()
      self.cancelPledgeError.assertDidNotEmitValue()

      self.scheduler.run()

      self.notifyDelegateCancelPledgeSuccess.assertDidNotEmitValue()
      self.cancelPledgeError.assertValues(["You can't cancel your pledge right now."])
    }
  }

  func testTrackingEvents() {
    let envelope = GraphMutationEmptyResponseEnvelope()
    let mockService = MockService(cancelBackingResult: .success(envelope))

    withEnvironment(apiService: mockService) {
      let project = Project.template

      let data = CancelPledgeViewData(
        project: project,
        projectCountry: project.country,
        projectName: project.name,
        omitUSCurrencyCode: project.stats.omitUSCurrencyCode,
        backingId: String(project.personalization.backing?.id ?? 0),
        pledgeAmount: project.personalization.backing?.pledgeAmount ?? 0
      )

      self.vm.inputs.configure(with: data)

      self.vm.inputs.viewDidLoad()

      XCTAssertEqual([], self.trackingClient.events)

      self.vm.inputs.cancelPledgeButtonTapped()

      XCTAssertEqual(["Cancel Pledge Button Clicked"], self.trackingClient.events)
    }
  }
}
