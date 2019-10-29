@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeSummaryViewModelTests: TestCase {
  private let vm: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  private let amountLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let amountLabelText = TestObserver<String, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()
  private let totalConversionLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
    self.vm.outputs.amountLabelAttributedText.observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.amountLabelAttributedText.map { $0.string }
      .observe(self.amountLabelText.observer)
    self.vm.outputs.totalConversionLabelText.observe(self.totalConversionLabelText.observer)
  }

  func testNotifyDelegateOpenHelpType() {
    let baseUrl = AppEnvironment.current.apiService.serverConfig.webBaseUrl
    let allCases = HelpType.allCases.filter { $0 != .contact }

    let allHelpTypeUrls = allCases.map { $0.url(withBaseUrl: baseUrl) }.compact()

    allHelpTypeUrls.forEach { self.vm.inputs.tapped($0) }

    self.notifyDelegateOpenHelpType.assertValues(allCases)
  }

  func testAmountAttributedText() {
    self.vm.inputs.configureWith(.template, total: 10)
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$10.00"])
  }

  func testTotalConversionText_NeedsConversion() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    self.vm.inputs.configureWith(project, total: 10)
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £20.00"])
  }

  func testTotalConversionText_NoConversionNeeded() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    self.vm.inputs.configureWith(project, total: 10)
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertDidNotEmitValue()
  }
}
