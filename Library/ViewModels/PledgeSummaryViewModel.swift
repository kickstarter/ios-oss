import KsApi
import Prelude
import ReactiveSwift
import UIKit

private enum Constants {
  public static let dateFormat = "MMMM d, yyyy"
}

public typealias PledgeSummaryViewData = (
  project: Project,
  total: Double,
  confirmationLabelHidden: Bool,
  pledgeHasNoReward: Bool?,
  pledgeOverTimeData: PledgePaymentPlansAndSelectionData?
)

public protocol PledgeSummaryViewModelInputs {
  func configure(with data: PledgeSummaryViewData)
  func tapped(_ url: URL)
  func viewDidLoad()
}

public protocol PledgeSummaryViewModelOutputs {
  var amountLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var confirmationLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var confirmationLabelHidden: Signal<Bool, Never> { get }
  var notifyDelegateOpenHelpType: Signal<HelpType, Never> { get }
  var pledgeOverTimeStackViewHidden: Signal<Bool, Never> { get }
  var pledgeOverTimeChargesText: Signal<String, Never> { get }
  var totalConversionLabelText: Signal<String, Never> { get }
  var titleLabelText: Signal<String, Never> { get }
}

public protocol PledgeSummaryViewModelType {
  var inputs: PledgeSummaryViewModelInputs { get }
  var outputs: PledgeSummaryViewModelOutputs { get }
}

public class PledgeSummaryViewModel: PledgeSummaryViewModelType,
  PledgeSummaryViewModelInputs, PledgeSummaryViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let projectAndPledgeTotal = initialData
      .map { project, total, _, _, _ in (project, total) }

    let pledgeHasNoReward = initialData
      .map { _, _, _, pledgeHasNoReward, _ in pledgeHasNoReward }

    let pledgeOverTimeData = initialData
      .map { _, _, _, _, pledgeOverTimeData in
        pledgeOverTimeData
      }

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

    self.titleLabelText = pledgeHasNoReward
      .map { hasNoRewards in
        featureNoShippingAtCheckout() && hasNoRewards == true
          ? Strings.Pledge_without_a_reward()
          : Strings.Pledge_amount()
      }

    self.confirmationLabelAttributedText = initialData.map { data in
      attributedConfirmationString(with: data)
    }

    let project = initialData.map(\.project)

    self.confirmationLabelHidden = Signal.combineLatest(initialData, project)
      .map { initialData, project in
        guard featurePostCampaignPledgeEnabled(), project.isInPostCampaignPledgingPhase else {
          return initialData.confirmationLabelHidden
        }

        return true
      }

    self.pledgeOverTimeStackViewHidden = pledgeOverTimeData.map { $0?.isPledgeOverTime ?? false }.negate()

    // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
    self.pledgeOverTimeChargesText = pledgeOverTimeData.skipNil()
      .map { "charged as \($0.paymentIncrements.count) payments" }
  }

  private let configureWithDataProperty = MutableProperty<PledgeSummaryViewData?>(nil)
  public func configure(with data: PledgeSummaryViewData) {
    self.configureWithDataProperty.value = data
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
  public let confirmationLabelAttributedText: Signal<NSAttributedString, Never>
  public let confirmationLabelHidden: Signal<Bool, Never>
  public let notifyDelegateOpenHelpType: Signal<HelpType, Never>
  public let pledgeOverTimeStackViewHidden: Signal<Bool, Never>
  public let pledgeOverTimeChargesText: Signal<String, Never>
  public let totalConversionLabelText: Signal<String, Never>
  public let titleLabelText: Signal<String, Never>

  public var inputs: PledgeSummaryViewModelInputs { return self }
  public var outputs: PledgeSummaryViewModelOutputs { return self }
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

private func attributedConfirmationString(with project: Project, pledgeTotal: Double) -> NSAttributedString {
  var date = ""

  if let deadline = project.dates.deadline {
    date = Format.date(secondsInUTC: deadline, template: Constants.dateFormat)
  }

  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country
  let pledgeTotal = Format.currency(pledgeTotal, country: projectCurrencyCountry)

  let font = UIFont.ksr_caption1()
  let foregroundColor = UIColor.ksr_support_400

  return Strings
    .If_the_project_reaches_its_funding_goal_you_will_be_charged_total_on_project_deadline_and_receive_proof_of_pledge(
      total: pledgeTotal,
      project_deadline: date
    )
    .attributed(
      with: font, foregroundColor: foregroundColor, attributes: [:], bolding: [pledgeTotal, date]
    )
}

private func attributedConfirmationPledgeOverTimeString(
  with project: Project,
  increments: [PledgePaymentIncrement]
) -> NSAttributedString {
  guard let firstIncrement = increments.first else { return NSAttributedString() }

  let date = Format.date(secondsInUTC: firstIncrement.scheduledCollection, template: Constants.dateFormat)

  let projectCurrencyCountry = projectCountry(forCurrency: project.stats.currency) ?? project.country
  let chargeAmount = Format.currency(firstIncrement.amount.amount, country: projectCurrencyCountry)

  let font = UIFont.ksr_caption1()
  let foregroundColor = UIColor.ksr_support_400

  // TODO: add strings translations [MBL-1860](https://kickstarter.atlassian.net/browse/MBL-1860)
  return "If the project reaches its funding goal, the first charge of \(chargeAmount) will be collected on \(date)."
    .attributed(
      with: font, foregroundColor: foregroundColor, attributes: [:], bolding: [chargeAmount, date]
    )
}

private func attributedConfirmationString(with data: PledgeSummaryViewData) -> NSAttributedString {
  if let plotData = data.pledgeOverTimeData, plotData.isPledgeOverTime {
    return attributedConfirmationPledgeOverTimeString(
      with: data.project,
      increments: plotData.paymentIncrements
    )
  }

  return attributedConfirmationString(with: data.project, pledgeTotal: data.total)
}
