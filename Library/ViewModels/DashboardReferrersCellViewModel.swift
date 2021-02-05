import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public struct ReferrersRowData {
  public let country: Project.Country
  public let referrers: [ProjectStatsEnvelope.ReferrerStats]
}

extension ReferrersRowData: Equatable {}
public func == (lhs: ReferrersRowData, rhs: ReferrersRowData) -> Bool {
  return lhs.country == rhs.country && lhs.referrers == rhs.referrers
}

public protocol DashboardReferrersCellViewModelInputs {
  /// Call when cell is loaded.
  func awakeFromNib()

  /// Call when the Backers button is tapped.
  func backersButtonTapped()

  /// Call to configure cell with cumulative and referral stats.
  func configureWith(
    cumulative: ProjectStatsEnvelope.CumulativeStats,
    project: Project,
    referralAggregates: ProjectStatsEnvelope.ReferralAggregateStats,
    referrers: [ProjectStatsEnvelope.ReferrerStats]
  )

  /// Call when the Percent button is tapped.
  func percentButtonTapped()

  /// Call when the Pledged button is tapped.
  func pledgedButtonTapped()

  /// Call when the Show more referrers button is tapped.
  func showMoreReferrersTapped()

  /// Call when the Source button is tapped.
  func sourceButtonTapped()
}

public protocol DashboardReferrersCellViewModelOutputs {
  /// Emits the average pledge text to be displayed.
  var averagePledgeText: Signal<String, Never> { get }

  /// Emits the custom percent text to be displayed.
  var customPercentText: Signal<String, Never> { get }

  /// Emits the pledged via custom text to be displayed.
  var customPledgedText: Signal<String, Never> { get }

  /// Emits the external pledge percentage to be displayed in a chart.
  var externalPercentage: Signal<Double, Never> { get }

  /// Emits the percent pledged via external text to be displayed.
  var externalPercentText: Signal<String, Never> { get }

  /// Emits the pledged via external text to be displayed.
  var externalPledgedText: Signal<String, Never> { get }

  /// Emits the internal pledge percentage to be displayed in a chart.
  var internalPercentage: Signal<Double, Never> { get }

  /// Emits the percent pledged via internal text to be displayed.
  var internalPercentText: Signal<String, Never> { get }

  /// Emits the pledged via internal text to be displayed.
  var internalPledgedText: Signal<String, Never> { get }

  /// Emits when should notify the delegate that referrer rows have been added to the stack view.
  var notifyDelegateAddedReferrerRows: Signal<Void, Never> { get }

  /// Emits the referrers row data to be displayed in each referrers stack view row.
  var referrersRowData: Signal<ReferrersRowData, Never> { get }

  /// Emits a boolean to determine when the show more referrers button should be hidden.
  var showMoreReferrersButtonHidden: Signal<Bool, Never> { get }
}

public protocol DashboardReferrersCellViewModelType {
  var inputs: DashboardReferrersCellViewModelInputs { get }
  var outputs: DashboardReferrersCellViewModelOutputs { get }
}

public final class DashboardReferrersCellViewModel: DashboardReferrersCellViewModelInputs,
  DashboardReferrersCellViewModelOutputs, DashboardReferrersCellViewModelType {
  public init() {
    let cumulativeProjectStats = self.cumulativeProjectStatsProperty.signal.skipNil()

    let country = cumulativeProjectStats.map { _, project, _, _ in project.country }

    let referralAggregates = cumulativeProjectStats.map { _, _, aggregates, _ in aggregates }

    let referrers = cumulativeProjectStats.map { _, _, _, stats in stats }

    self.averagePledgeText = cumulativeProjectStats
      .map { cumulative, project, _, _ in
        Format.currency(cumulative.averagePledge, country: project.country)
      }

    let customPledgedAmount = referralAggregates
      .map { $0.custom }

    let externalPledgedAmount = referralAggregates
      .map { $0.external }

    let internalPledgedAmount = referralAggregates
      .map { $0.kickstarter }

    let pledge = cumulativeProjectStats
      .map { cumulative, _, _, _ in cumulative.pledged }

    self.customPercentText = Signal.combineLatest(customPledgedAmount, pledge)
      .map { customAmount, pledged in
        pledged == 0 ? Format.percentage(0.0) : Format.percentage(customAmount / Double(pledged))
      }

    self.customPledgedText = Signal.combineLatest(customPledgedAmount, country)
      .map { pledged, country in Format.currency(Int(pledged), country: country) }

    self.externalPercentage = Signal.combineLatest(externalPledgedAmount, pledge)
      .map { externalAmount, pledged in pledged == 0 ? 0.0 : externalAmount / Double(pledged) }

    self.externalPercentText = self.externalPercentage.map { Format.percentage($0) }

    self.externalPledgedText = Signal.combineLatest(externalPledgedAmount, country)
      .map { pledged, country in Format.currency(Int(pledged), country: country) }

    self.internalPercentage = Signal.combineLatest(internalPledgedAmount, pledge)
      .map { internalAmount, pledged in pledged == 0 ? 0.0 : internalAmount / Double(pledged) }

    self.internalPercentText = self.internalPercentage.map { Format.percentage($0) }

    self.internalPledgedText = Signal.combineLatest(internalPledgedAmount, country)
      .map { pledged, country in Format.currency(Int(pledged), country: country) }

    let sortedByPledgedOrPercent = referrers.sort { $0.pledged > $1.pledged }

    let initialSort = sortedByPledgedOrPercent

    let sortedByBackers = referrers
      .takeWhen(self.backersButtonTappedProperty.signal)
      .sort { $0.backersCount > $1.backersCount }

    let sortedByPercent = sortedByPledgedOrPercent
      .takeWhen(self.percentButtonTappedProperty.signal)

    let sortedByPledged = sortedByPledgedOrPercent
      .takeWhen(self.pledgedButtonTappedProperty.signal)

    let sortedBySource = referrers
      .takeWhen(self.sourceButtonTappedProperty.signal)
      .sort { $0.referrerName.lowercased() < $1.referrerName.lowercased() }

    let allReferrers = Signal.merge(
      initialSort,
      sortedByBackers,
      sortedByPercent,
      sortedByPledged,
      sortedBySource
    )

    let allReferrersRowData = Signal.combineLatest(country, allReferrers)
      .map(ReferrersRowData.init)

    let showMoreReferrersButtonIsHidden = Signal.merge(
      referrers.map { $0.count < 6 },
      self.showMoreReferrersTappedProperty.signal.mapConst(true)
    )

    self.showMoreReferrersButtonHidden = showMoreReferrersButtonIsHidden.skipRepeats()

    self.referrersRowData = Signal.combineLatest(allReferrersRowData, showMoreReferrersButtonIsHidden)
      .map { rowData, isHidden in
        let refCount = rowData.referrers.count
        let maxReferrers = isHidden ? rowData.referrers :
          Array(rowData.referrers[0..<min(3, refCount)])
        return ReferrersRowData(country: rowData.country, referrers: maxReferrers)
      }
      .skipRepeats(==)

    self.notifyDelegateAddedReferrerRows = self.showMoreReferrersTappedProperty.signal
  }

  fileprivate let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let backersButtonTappedProperty = MutableProperty(())
  public func backersButtonTapped() {
    self.backersButtonTappedProperty.value = ()
  }

  private let cumulativeProjectStatsProperty = MutableProperty<
    (
      ProjectStatsEnvelope.CumulativeStats,
      Project,
      ProjectStatsEnvelope.ReferralAggregateStats,
      [ProjectStatsEnvelope.ReferrerStats]
    )?
  >(nil)
  public func configureWith(
    cumulative: ProjectStatsEnvelope.CumulativeStats,
    project: Project,
    referralAggregates: ProjectStatsEnvelope.ReferralAggregateStats,
    referrers: [ProjectStatsEnvelope.ReferrerStats]
  ) {
    self.cumulativeProjectStatsProperty.value = (cumulative, project, referralAggregates, referrers)
  }

  fileprivate let percentButtonTappedProperty = MutableProperty(())
  public func percentButtonTapped() {
    self.percentButtonTappedProperty.value = ()
  }

  fileprivate let pledgedButtonTappedProperty = MutableProperty(())
  public func pledgedButtonTapped() {
    self.pledgedButtonTappedProperty.value = ()
  }

  fileprivate let showMoreReferrersTappedProperty = MutableProperty(())
  public func showMoreReferrersTapped() {
    self.showMoreReferrersTappedProperty.value = ()
  }

  fileprivate let sourceButtonTappedProperty = MutableProperty(())
  public func sourceButtonTapped() {
    self.sourceButtonTappedProperty.value = ()
  }

  public let averagePledgeText: Signal<String, Never>
  public let customPercentText: Signal<String, Never>
  public let customPledgedText: Signal<String, Never>
  public let externalPercentage: Signal<Double, Never>
  public let externalPercentText: Signal<String, Never>
  public let externalPledgedText: Signal<String, Never>
  public let internalPercentage: Signal<Double, Never>
  public let internalPercentText: Signal<String, Never>
  public let internalPledgedText: Signal<String, Never>
  public let notifyDelegateAddedReferrerRows: Signal<Void, Never>
  public let referrersRowData: Signal<ReferrersRowData, Never>
  public let showMoreReferrersButtonHidden: Signal<Bool, Never>

  public var inputs: DashboardReferrersCellViewModelInputs { return self }
  public var outputs: DashboardReferrersCellViewModelOutputs { return self }
}
