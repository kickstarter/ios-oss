import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol PostCampaignPledgeSummaryTotalViewModelInputs {
  func configure(with data: PledgeSummaryViewData)
  func viewDidLoad()
}

public protocol PostCampaignPledgeSummaryTotalViewModelOutputs {
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var totalConversionLabelText: Signal<String, Never> { get }
}

public protocol PostCampaignPledgeSummaryTotalViewModelType {
  var inputs: PostCampaignPledgeSummaryTotalViewModelInputs { get }
  var outputs: PostCampaignPledgeSummaryTotalViewModelOutputs { get }
}

public class PostCampaignPledgeSummaryTotalViewModel: PostCampaignPledgeSummaryTotalViewModelType,
  PostCampaignPledgeSummaryTotalViewModelInputs, PostCampaignPledgeSummaryTotalViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let projectAndPledgeTotal = initialData
      .map { project, total, _ in (project, total) }

    self.amountLabelAttributedText = projectAndPledgeTotal
      .map(attributedCurrency(with:total:))
      .skipNil()

    self.totalConversionLabelText = projectAndPledgeTotal
      .filter { project, _ in project.stats.needsConversion }
      .map { project, total in
        let convertedTotal = total * Double(project.stats.currentCurrencyRate ?? project.stats.staticUsdRate)
        let currentCountry = project.stats.currentCountry ?? Project.Country.us

        return Format.currency(
          convertedTotal,
          country: currentCountry,
          omitCurrencyCode: project.stats.omitUSCurrencyCode,
          roundingMode: .halfUp,
          maximumFractionDigits: 2,
          minimumFractionDigits: 2
        )
      }
      .map { Strings.About_reward_amount(reward_amount: $0) }
  }

  private let configureWithDataProperty = MutableProperty<PledgeSummaryViewData?>(nil)
  public func configure(with data: PledgeSummaryViewData) {
    self.configureWithDataProperty.value = data
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let amountLabelAttributedText: Signal<NSAttributedString, Never>
  public let totalConversionLabelText: Signal<String, Never>

  public var inputs: PostCampaignPledgeSummaryTotalViewModelInputs { return self }
  public var outputs: PostCampaignPledgeSummaryTotalViewModelOutputs { return self }
}

private func attributedCurrency(with project: Project, total: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_support_700])
  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country

  return Format.attributedCurrency(
    total,
    country: projectCurrencyCountry,
    omitCurrencyCode: project.stats.omitUSCurrencyCode,
    defaultAttributes: defaultAttributes,
    superscriptAttributes: checkoutCurrencySuperscriptAttributes()
  )
}
