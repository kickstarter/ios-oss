import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public typealias PledgeTableViewData = (
  amount: Double,
  currency: String,
  delivery: String,
  shipping: (location: String, amount: NSAttributedString?),
  isLoggedIn: Bool
)

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var reloadWithData: Signal<PledgeTableViewData, NoError> { get }
}

public protocol PledgeViewModelType {
  var inputs: PledgeViewModelInputs { get }
  var outputs: PledgeViewModelOutputs { get }
}

public class PledgeViewModel: PledgeViewModelType, PledgeViewModelInputs, PledgeViewModelOutputs {
  public init() {
    let projectAndReward = Signal.combineLatest(
      self.configureProjectAndRewardProperty.signal, self.viewDidLoadProperty.signal
    )
      .map(first)
      .skipNil()

    let isLoggedIn = projectAndReward
      .map { _ in AppEnvironment.current.currentUser }
      .map(isNotNil)

    let amountCurrencyDeliveryShipping = projectAndReward.signal
      .map { (project, reward) -> (Double, String, String, (String, NSAttributedString?)) in
        let amount = reward.minimum
        let currency = currencySymbol(forCountry: project.country).trimmed()
        let delivery = reward.estimatedDeliveryOn
          .map { Format.date(secondsInUTC: $0, template: "MMMMyyyy", timeZone: UTCTimeZone) } ?? ""
        let shipping = (
          "Brooklyn",
          Format.attributedCurrency(
            7.5,
            country: project.country,
            omitCurrencyCode: project.stats.omitUSCurrencyCode,
            defaultAttributes: checkoutCurrencyDefaultAttributes(),
            superscriptAttributes: checkoutCurrencySuperscriptAttributes()
          )
        )

        return (amount, currency, delivery, shipping)
    }

    self.reloadWithData = Signal.combineLatest(amountCurrencyDeliveryShipping, isLoggedIn)
      .map { amountCurrencyDeliveryShipping, isLoggedIn in
        let (amount, currency, delivery, shipping) = amountCurrencyDeliveryShipping

        return (amount, currency, delivery, shipping, isLoggedIn)
    }
  }

  private let configureProjectAndRewardProperty = MutableProperty<(Project, Reward)?>(nil)
  public func configureWith(project: Project, reward: Reward) {
    self.configureProjectAndRewardProperty.value = (project, reward)
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let reloadWithData: Signal<PledgeTableViewData, NoError>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
