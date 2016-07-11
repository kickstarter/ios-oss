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

  /// Emits the amount pledged and percentage to be displayed.
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

    self.pledgedText = countryReferrer
      .map { country, referrer in
        Format.currency(referrer.pledged, country: country) + " ("
          + Format.percentage(referrer.percentageOfDollars) + ")"
    }

    self.sourceText = countryReferrer.map { _, referrer in referrer.referrerName }

    self.textColor = countryReferrer.map { _, referrer in
      switch referrer.referrerType {
      case .`internal`:
        return .ksr_green_700
      case .external:
        return .ksr_orange_400
      default:
        return .ksr_violet_850
      }
    }
  }

  private let countryReferrerProperty =
    MutableProperty<(Project.Country, ProjectStatsEnvelope.ReferrerStats)?>(nil)
  public func configureWith(country country: Project.Country, referrer: ProjectStatsEnvelope.ReferrerStats) {
    self.countryReferrerProperty.value = (country, referrer)
  }

  public let backersText: Signal<String, NoError>
  public let pledgedText: Signal<String, NoError>
  public let sourceText: Signal<String, NoError>
  public let textColor: Signal<UIColor, NoError>

  public var inputs: DashboardReferrerRowStackViewViewModelInputs { return self }
  public var outputs: DashboardReferrerRowStackViewViewModelOutputs { return self }
}
