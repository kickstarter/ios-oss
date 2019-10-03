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
  private let popCancelPledgeViewController = TestObserver<Void, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.cancellationDetailsAttributedText
      .observe(self.cancellationDetailsAttributedTextAttributedString.observer)
    self.vm.outputs.cancellationDetailsAttributedText.map { $0.string }
      .observe(self.cancellationDetailsAttributedTextString.observer)
    self.vm.outputs.popCancelPledgeViewController.observe(self.popCancelPledgeViewController.observer)
  }

  func testConfigureCancelPledgeView() {
    let backing = Backing.template
      |> Backing.lens.amount .~ 5
    let project = Project.cosmicSurgery
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: project, backing: backing)
    self.vm.inputs.viewDidLoad()

    let cancellationString = "Are you sure you wish to cancel your $5 pledge to Cosmic Surgery?"
    var pledgeAmountRange: NSRange = (cancellationString as NSString).range(of: "$5")
    var projectNameRange: NSRange = (cancellationString as NSString).range(of: "Cosmic Surgery")

    let boldFontAttribute = UIFont.ksr_callout().bolded

    self.cancellationDetailsAttributedTextString
      .assertValues([cancellationString])

    XCTAssertEqual(self.cancellationDetailsAttributedTextAttributedString.values
      .compactMap { $0.attribute(.font,
                                 at: pledgeAmountRange.location,
                                 effectiveRange: &pledgeAmountRange) } as? [UIFont],
                   [boldFontAttribute])
    XCTAssertEqual(self.cancellationDetailsAttributedTextAttributedString.values
      .compactMap { $0.attribute(.font,
                                 at: projectNameRange.location,
                                 effectiveRange: &projectNameRange) } as? [UIFont],
                   [boldFontAttribute])

    self.vm.inputs.traitCollectionDidChange()

    self.cancellationDetailsAttributedTextString
      .assertValues([cancellationString,
                     cancellationString])
    XCTAssertEqual(self.cancellationDetailsAttributedTextAttributedString.values
      .compactMap { $0.attribute(.font,
                                 at: pledgeAmountRange.location,
                                 effectiveRange: &pledgeAmountRange) } as? [UIFont],
                   [boldFontAttribute, boldFontAttribute])
    XCTAssertEqual(self.cancellationDetailsAttributedTextAttributedString.values
      .compactMap { $0.attribute(.font,
                                 at: projectNameRange.location,
                                 effectiveRange: &projectNameRange) } as? [UIFont],
                   [boldFontAttribute, boldFontAttribute])
  }

  func testGoBackButtonTapped() {
    self.vm.inputs.configure(with: Project.template, backing: Backing.template)

    self.popCancelPledgeViewController.assertDidNotEmitValue()

    self.vm.inputs.goBackButtonTapped()

    self.popCancelPledgeViewController.assertValueCount(1)
  }
}
