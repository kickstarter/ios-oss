@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PostCampaignPledgeSummaryTotalViewModelTests: TestCase {
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

  func testAmountAttributedText_US_ProjectCurrency_RegularReward() {
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: (project, total: 30, false))
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$30.00"], "Total is added to reward minimum")
  }

  func testAmountAttributedText_NonUS_ProjectCurrency_RegularReward() {
    let project = Project.cosmicSurgery
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us

    self.vm.inputs.configure(with: (project, total: 30, false))
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues([" MX$ 30.00"], "Total is added to reward minimum")
  }

  func testAmountAttributedText_US_ProjectCurrency_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.country .~ Project.Country.us
    self.vm.inputs.configure(with: (project, total: 10, false))

    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$10.00"], "Total is used directly")
  }

  func testAmountAttributedText_NonUS_ProjectCurrency_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.mx.currencyCode
      |> Project.lens.country .~ Project.Country.us
    let pledgeSummaryViewData = PledgeSummaryViewData(project, total: 10, false)

    self.vm.inputs.configure(with: pledgeSummaryViewData)

    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues([" MX$ 10.00"], "Total is used directly")
  }

  func testTotalConversionText_NeedsConversion_NoReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    self.vm.inputs.configure(with: (project, total: 10, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £20.00"])
  }

  func testTotalConversionText_NeedsConversion_RegularReward() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    self.vm.inputs.configure(with: (project, total: 20, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £40.00"])
  }

  func testTotalConversionText_NoConversionNeeded() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ nil
      |> Project.lens.stats.currentCurrencyRate .~ nil

    self.vm.inputs.configure(with: (project, total: 10, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertDidNotEmitValue()
  }
}
