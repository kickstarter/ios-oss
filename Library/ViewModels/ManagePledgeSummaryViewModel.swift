import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct ManagePledgeSummaryViewData: Equatable {
  public let backerId: Int
  public let backerName: String
  public let backerSequence: Int
  public let backingState: BackingState
  public let currentUserIsCreatorOfProject: Bool
  public let locationName: String?
  public let needsConversion: Bool
  public let omitUSCurrencyCode: Bool
  public let pledgeAmount: Double
  public let pledgedOn: TimeInterval
  public let projectCountry: Project.Country
  public let projectDeadline: TimeInterval
  public let projectState: ProjectState
  public let shippingAmount: Double?
}

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
  var configurePledgeAmountSummaryViewWithData: Signal<PledgeAmountSummaryViewData, Never> { get }
  var configurePledgeStatusLabelViewWithProject: Signal<PledgeStatusLabelViewData, Never> { get }
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

    self.configurePledgeStatusLabelViewWithProject = data.map(pledgeStatusLabelViewData)

    self.configurePledgeAmountSummaryViewWithData = data.map(pledgeAmountSummaryViewData)

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

    self.backingDateText = data.map(\.pledgedOn)
      .map(formattedPledgeDate)

    self.totalAmountText = data.map { ($0.projectCountry, $0.pledgeAmount, $0.omitUSCurrencyCode) }
      .map { projectCountry, pledgeAmount, omitUSCurrencyCode in
        attributedCurrency(with: projectCountry, amount: pledgeAmount, omitUSCurrencyCode: omitUSCurrencyCode)
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
  public let configurePledgeStatusLabelViewWithProject: Signal<PledgeStatusLabelViewData, Never>
  public let configurePledgeAmountSummaryViewWithData: Signal<PledgeAmountSummaryViewData, Never>
  public let totalAmountText: Signal<NSAttributedString, Never>

  public var inputs: ManagePledgeSummaryViewModelInputs { return self }
  public var outputs: ManagePledgeSummaryViewModelOutputs { return self }
}

private func formattedPledgeDate(_ timeInterval: TimeInterval) -> String {
  let formattedDate = Format.date(secondsInUTC: timeInterval, dateStyle: .long, timeStyle: .none)
  return Strings.As_of_pledge_date(pledge_date: formattedDate)
}

private func pledgeAmountSummaryViewData(
  with data: ManagePledgeSummaryViewData
) -> PledgeAmountSummaryViewData {
  return .init(
    projectCountry: data.projectCountry,
    pledgeAmount: data.pledgeAmount,
    pledgedOn: data.pledgedOn,
    shippingAmount: data.shippingAmount,
    locationName: data.locationName,
    omitUSCurrencyCode: data.omitUSCurrencyCode
  )
}

private func pledgeStatusLabelViewData(with data: ManagePledgeSummaryViewData) -> PledgeStatusLabelViewData {
  return .init(
    currentUserIsCreatorOfProject: data.currentUserIsCreatorOfProject,
    needsConversion: data.needsConversion,
    pledgeAmount: data.pledgeAmount,
    projectCountry: data.projectCountry,
    projectDeadline: data.projectDeadline,
    projectState: data.projectState,
    backingState: data.backingState
  )
}

private func attributedCurrency(
  with country: Project.Country,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_green_500])
  let superscriptAttributes = checkoutCurrencySuperscriptAttributes()
  guard
    let attributedCurrency = Format.attributedCurrency(
      amount,
      country: country,
      omitCurrencyCode: omitUSCurrencyCode,
      defaultAttributes: defaultAttributes,
      superscriptAttributes: superscriptAttributes
    ) else { return nil }

  return attributedCurrency
}
