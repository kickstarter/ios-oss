import KsApi
import Foundation
import Prelude
import ReactiveSwift
import Result

public protocol PledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward)
  func viewDidLoad()
}

public protocol PledgeViewModelOutputs {
  var amountCurrencyAndShipping: Signal<(Double, String, (String, NSAttributedString?)), NoError> { get }
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

    self.amountCurrencyAndShipping = projectAndReward.signal
      .map { (project, reward) in
        (
          reward.minimum,
          currencySymbol(forCountry: project.country).trimmed(),
          (
            "Brooklyn",
            Format.attributedCurrency(
              7.5,
              country: project.country,
              omitCurrencyCode: project.stats.omitUSCurrencyCode,
              defaultAttributes: checkoutCurrencyDefaultAttributes(),
              superscriptAttributes: checkoutCurrencySuperscriptAttributes()
            )
          )
        )
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

  public let amountCurrencyAndShipping: Signal<(Double, String, (String, NSAttributedString?)), NoError>

  public var inputs: PledgeViewModelInputs { return self }
  public var outputs: PledgeViewModelOutputs { return self }
}
