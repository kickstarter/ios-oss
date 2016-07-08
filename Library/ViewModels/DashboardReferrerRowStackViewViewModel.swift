import KsApi
import Prelude
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardReferrerRowStackViewViewModelInputs {
  /// Call to configure cell with referrer data.
  func configureWith(country country: Project.Country, referrer: ProjectStatsEnvelope.ReferrerStats)
}

public protocol DashboardReferrerRowStackViewViewModelOutputs {
  /// Emits the number of backers to be displayed.
  var backersText: Signal<String, NoError> { get }

  /// Emits the percentage of dollars to be displayed.
  var percentText: Signal<String, NoError> { get }

  /// Emits the amount pledged to be displayed.
  var pledgedText: Signal<String, NoError> { get }

  /// Emits the referrer source to be displayed.
  var sourceText: Signal<String, NoError> { get }

  /// Emits the text color of the row labels to be displayed.
  var textColor: Signal<UIColor, NoError> { get }
}

public protocol DashboardReferrerRowStackViewViewModelType {
  var inputs: DashboardReferrerRowStackViewViewModelInputs { get }
  var outputs: DashboardReferrerRowStackViewViewModelOutputs { get }
}

public final class DashboardReferrerRowStackViewViewModel: DashboardReferrerRowStackViewViewModelInputs,
  DashboardReferrerRowStackViewViewModelOutputs, DashboardReferrerRowStackViewViewModelType {

  public init() {
    let countryReferrer = self.countryReferrerProperty.signal.ignoreNil()

    self.backersText = countryReferrer.map { _, referrer in Format.wholeNumber(referrer.backersCount) }

    self.percentText = countryReferrer.map { _, referrer in Format.percentage(referrer.percentageOfDollars) }

    self.pledgedText = countryReferrer
      .map { country, referrer in
        Format.currency(referrer.pledged, country: country)
    }

    self.sourceText = countryReferrer.map { _, referrer in referrer.referrerName }

    self.textColor = countryReferrer.map { _, referrer in
      referrer.referrerType == .`internal` ? UIColor.ksr_green(weight: 400) : UIColor.ksr_darkGrayText
    }
  }

  private let countryReferrerProperty =
    MutableProperty<(Project.Country, ProjectStatsEnvelope.ReferrerStats)?>(nil)
  public func configureWith(country country: Project.Country, referrer: ProjectStatsEnvelope.ReferrerStats) {
    self.countryReferrerProperty.value = (country, referrer)
  }

  public let backersText: Signal<String, NoError>
  public let percentText: Signal<String, NoError>
  public let pledgedText: Signal<String, NoError>
  public let sourceText: Signal<String, NoError>
  public let textColor: Signal<UIColor, NoError>

  public var inputs: DashboardReferrerRowStackViewViewModelInputs { return self }
  public var outputs: DashboardReferrerRowStackViewViewModelOutputs { return self }
}
