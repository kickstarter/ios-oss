@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class PledgeSummaryViewModelTests: TestCase {
  private let vm: PledgeSummaryViewModelType = PledgeSummaryViewModel()

  private let amountLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let amountLabelText = TestObserver<String, Never>()

  private let confirmationLabelAttributedText = TestObserver<NSAttributedString, Never>()
  private let confirmationLabelText = TestObserver<String, Never>()
  private let confirmationLabelHidden = TestObserver<Bool, Never>()
  private let notifyDelegateOpenHelpType = TestObserver<HelpType, Never>()
  private let totalConversionLabelText = TestObserver<String, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.notifyDelegateOpenHelpType.observe(self.notifyDelegateOpenHelpType.observer)
    self.vm.outputs.amountLabelAttributedText.observe(self.amountLabelAttributedText.observer)
    self.vm.outputs.amountLabelAttributedText.map { $0.string }
      .observe(self.amountLabelText.observer)
    self.vm.outputs.confirmationLabelAttributedText.observe(self.confirmationLabelAttributedText.observer)
    self.vm.outputs.confirmationLabelAttributedText.map { $0.string }
      .observe(self.confirmationLabelText.observer)
    self.vm.outputs.confirmationLabelHidden.observe(self.confirmationLabelHidden.observer)
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
    self.vm.inputs.configure(with: (.template, total: 10, false))
    self.vm.inputs.viewDidLoad()

    self.amountLabelText.assertValues(["$10.00"])
  }

  func testTotalConversionText_NeedsConversion() {
    let project = Project.template
      |> Project.lens.stats.currency .~ Project.Country.us.currencyCode
      |> Project.lens.stats.currentCurrency .~ Project.Country.gb.currencyCode
      |> Project.lens.stats.currentCurrencyRate .~ 2.0

    self.vm.inputs.configure(with: (project, total: 10, false))
    self.vm.inputs.viewDidLoad()

    self.totalConversionLabelText.assertValues(["About £20.00"])
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

  func testUpdateContext_ConfirmationLabel() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.USD.rawValue

      self.vm.inputs.configure(with: (project: project, total: 10, false))
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged on November 1, 2019."
      ])
    }
  }

  func testUpdateContext_ConfirmationLabel_Hidden() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone.init(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.USD.rawValue

      self.vm.inputs.configure(with: (project: project, total: 10, true))
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([true])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged on November 1, 2019."
      ])
    }
  }

  func testUpdateContext_ConfirmationLabelShowsTotalAmount() {
    let dateComponents = DateComponents()
      |> \.month .~ 11
      |> \.day .~ 1
      |> \.year .~ 2_019
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)

    let calendar = Calendar(identifier: .gregorian)
      |> \.timeZone .~ TimeZone(secondsFromGMT: 0)!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en")) {
      let date = AppEnvironment.current.calendar.date(from: dateComponents)

      let project = Project.template
        |> Project.lens.dates.deadline .~ date!.timeIntervalSince1970
        |> Project.lens.stats.currentCurrency .~ Currency.USD.rawValue
        |> Project.lens.stats.currency .~ Currency.HKD.rawValue
        |> Project.lens.country .~ .hk

      self.vm.inputs.configure(with: (project: project, total: 10, false))
      self.vm.inputs.viewDidLoad()

      self.confirmationLabelHidden.assertValues([false])
      self.confirmationLabelAttributedText.assertValueCount(1)
      self.confirmationLabelText.assertValues([
        "If the project reaches its funding goal, you will be charged HK$ 10 on November 1, 2019."
      ])
    }
  }
}
