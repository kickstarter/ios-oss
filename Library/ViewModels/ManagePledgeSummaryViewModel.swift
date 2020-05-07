import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias ManagePledgeSummaryViewData = (
  project: Project,
  pledgeAmount: Double,
  backerId: Int,
  backerName: String,
  backerSequence: Int,
  pledgeDate: TimeInterval
)

public protocol ManagePledgeSummaryViewModelInputs {
  func configureWith(_ data: ManagePledgeSummaryViewData)
  func viewDidLoad()
}

public protocol ManagePledgeSummaryViewModelOutputs {
  var backerImageURLAndPlaceholderImageName: Signal<(URL, String), Never> { get }
  var backerNameLabelHidden: Signal<Bool, Never> { get }
  var backerNameText: Signal<String, Never> { get }
  var backerNumberText: Signal<String, Never> { get }
  var backingDateText: Signal<String, Never> { get }
  var circleAvatarViewHidden: Signal<Bool, Never> { get }
  var configurePledgeAmountSummaryViewWithProject: Signal<Project, Never> { get }
  var configurePledgeStatusLabelViewWithProject: Signal<Project, Never> { get }
  var totalAmountText: Signal<NSAttributedString, Never> { get }
}

public protocol ManagePledgeSummaryViewModelType {
  var inputs: ManagePledgeSummaryViewModelInputs { get }
  var outputs: ManagePledgeSummaryViewModelOutputs { get }
}

public class ManagePledgeSummaryViewModel: ManagePledgeSummaryViewModelType,
  ManagePledgeSummaryViewModelInputs, ManagePledgeSummaryViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.dataSignal,
      self.viewDidLoadSignal
    )
    .map(first)

    let project = data.map(\.project)

    self.configurePledgeStatusLabelViewWithProject = project
    self.configurePledgeAmountSummaryViewWithProject = project

    let userAndIsBackingProject = data.map(\.backerId)
      .filterMap { backerId -> (User, Bool)? in
        guard let user = AppEnvironment.current.currentUser else {
          return nil
        }

        return (user, backerId == user.id)
      }

    self.backerNameLabelHidden = userAndIsBackingProject.map(second).negate()
    self.circleAvatarViewHidden = userAndIsBackingProject.map(second).negate()

    let userBackingProject = userAndIsBackingProject
      .filter(second >>> isTrue)
      .map(first)

    self.backerNameText = userBackingProject
      .map(\.name)

    self.backerImageURLAndPlaceholderImageName = userBackingProject
      .map(\.avatar.small)
      .map(URL.init)
      .skipNil()
      .map { ($0, "avatar--placeholder") }

    self.backerNumberText = data.map(\.backerSequence)
      .map { Strings.backer_modal_backer_number(backer_number: Format.wholeNumber($0)) }

    self.backingDateText = data.map(\.pledgeDate)
      .map(formattedPledgeDate)

    self.totalAmountText = data
      .map { project, pledgeAmount, _, _, _, _ in
        attributedCurrency(with: project, amount: pledgeAmount)
      }
      .skipNil()
  }

  private let (dataSignal, dataObserver) = Signal<ManagePledgeSummaryViewData, Never>.pipe()
  public func configureWith(_ data: ManagePledgeSummaryViewData) {
    self.dataObserver.send(value: data)
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let backerImageURLAndPlaceholderImageName: Signal<(URL, String), Never>
  public let backerNameLabelHidden: Signal<Bool, Never>
  public let backerNameText: Signal<String, Never>
  public let backerNumberText: Signal<String, Never>
  public let backingDateText: Signal<String, Never>
  public let circleAvatarViewHidden: Signal<Bool, Never>
  public let configurePledgeStatusLabelViewWithProject: Signal<Project, Never>
  public let configurePledgeAmountSummaryViewWithProject: Signal<Project, Never>
  public let totalAmountText: Signal<NSAttributedString, Never>

  public var inputs: ManagePledgeSummaryViewModelInputs { return self }
  public var outputs: ManagePledgeSummaryViewModelOutputs { return self }
}

private func formattedPledgeDate(_ timeInterval: TimeInterval) -> String {
  let formattedDate = Format.date(secondsInUTC: timeInterval, dateStyle: .long, timeStyle: .none)
  return Strings.As_of_pledge_date(pledge_date: formattedDate)
}

private func attributedCurrency(with project: Project, amount: Double) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      country: project.country,
      omitCurrencyCode: project.stats.omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  return attributedCurrency
}
