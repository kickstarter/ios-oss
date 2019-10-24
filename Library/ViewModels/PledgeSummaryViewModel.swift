import Foundation
import Prelude
import ReactiveSwift
import KsApi

public protocol PledgeSummaryViewModelInputs {
  func tapped(_ url: URL)
  func configureWith(_ project: Project, total: Double)
  func viewDidLoad()
}

public protocol PledgeSummaryViewModelOutputs {
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
  var totalConversionLabelText: Signal<String, Never> { get }
}

public protocol PledgeSummaryViewModelType {
  var inputs: PledgeSummaryViewModelInputs { get }
  var outputs: PledgeSummaryViewModelOutputs { get }
}

public class PledgeSummaryViewModel: PledgeSummaryViewModelType,
  PledgeSummaryViewModelInputs, PledgeSummaryViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(self.configureWithProjectAndTotalProperty.signal.skipNil(),
                                           self.viewDidLoadProperty.signal)
      .map(first)

    self.amountLabelAttributedText = initialData
      .map(attributedCurrency(with:total:))
      .skipNil()

    self.totalConversionLabelText = initialData
      .filter { project, _ in project.stats.needsConversion }
      .map { project, total in
        let convertedTotal = total * Double(project.stats.currentCurrencyRate ?? project.stats.staticUsdRate)
        let currentCountry = project.stats.currentCountry ?? Project.Country.us

        return Format.currency(
          convertedTotal,
          country: currentCountry,
          omitCurrencyCode: project.stats.omitUSCurrencyCode,
          roundingMode: .halfUp,
          maximumFractionDigits: 2
        )
      }
      .map { Strings.About_reward_amount(reward_amount: $0) }

    self.notifyDelegateOpenHelpType = self.tappedUrlSignal.map { url -> HelpType? in
      let helpType = HelpType.allCases.filter { helpType in
        url.absoluteString == helpType.url(
          withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl
        )?.absoluteString
      }
      .first

      return helpType
    }
    .skipNil()
  }

  private let configureWithProjectAndTotalProperty = MutableProperty<(Project, Double)?>(nil)
  public func configureWith(_ project: Project, total: Double) {
    self.configureWithProjectAndTotalProperty.value = (project, total)
  }

  private let (tappedUrlSignal, tappedUrlObserver) = Signal<URL, Never>.pipe()
  public func tapped(_ url: URL) {
    self.tappedUrlObserver.send(value: url)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let amountLabelAttributedText: Signal<NSAttributedString, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let totalConversionLabelText: Signal<String, Never>

  public var inputs: PledgeSummaryViewModelInputs { return self }
  public var outputs: PledgeSummaryViewModelOutputs { return self }
}

private func attributedCurrency(with project: Project, total: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
  return Format.attributedCurrency(
    total,
    country: project.country,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    defaultAttributes: defaultAttributes,
    superscriptAttributes: checkoutCurrencySuperscriptAttributes()
  )
}
