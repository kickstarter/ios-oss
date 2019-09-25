import Foundation
import KsApi
import PassKit
import Prelude
import ReactiveSwift

public protocol UpdatePledgeViewModelInputs {
  func configureWith(project: Project, reward: Reward, refTag: RefTag?)
  func pledgeAmountDidUpdate(to amount: Double)
  func shippingRuleSelected(_ shippingRule: ShippingRule)
  func traitCollectionDidChange()
  func viewDidLoad()
}

public protocol UpdatePledgeViewModelOutputs {
  var configureSummaryViewControllerWithData: Signal<(Project, Double), Never> { get }
  var configureWithData: Signal<(project: Project, reward: Reward), Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var confirmationLabelAttributedText: Signal<NSAttributedString, Never> { get }
}

public protocol UpdatePledgeViewModelType {
  var inputs: UpdatePledgeViewModelInputs { get }
  var outputs: UpdatePledgeViewModelOutputs { get }
}

public class UpdatePledgeViewModel: UpdatePledgeViewModelType, UpdatePledgeViewModelInputs,
  UpdatePledgeViewModelOutputs {
  public init() {
    let initialData = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)
    .skipNil()

    let project = initialData.map(first)
    let reward = initialData.map(second)

    let pledgeAmount = Signal.merge(
      self.pledgeAmountSignal,
      reward.map { $0.minimum }
    )

    let initialShippingAmount = initialData.mapConst(0.0)
    let shippingAmount = self.shippingRuleSelectedSignal
      .map { $0.cost }
    let shippingCost = Signal.merge(shippingAmount, initialShippingAmount)

    let pledgeTotal = Signal.combineLatest(pledgeAmount, shippingCost).map(+)

    self.configureWithData = initialData.map { (project: $0.0, reward: $0.1) }

    self.configureSummaryViewControllerWithData = project
      .takePairWhen(pledgeTotal)
      .map { project, total in (project, total) }

    self.shippingLocationViewHidden = reward
      .map { $0.shipping.enabled }
      .negate()

    self.confirmationLabelAttributedText = Signal.merge(
      project,
      project.takeWhen(self.traitCollectionDidChangeSignal)
    )
    .map(attributedConfirmationString(with:))
    .skipNil()
  }

  // MARK: - Inputs

  private let configureWithDataProperty = MutableProperty<(Project, Reward, RefTag?)?>(nil)
  public func configureWith(project: Project, reward: Reward, refTag: RefTag?) {
    self.configureWithDataProperty.value = (project, reward, refTag)
  }

  private let (pledgeAmountSignal, pledgeAmountObserver) = Signal<Double, Never>.pipe()
  public func pledgeAmountDidUpdate(to amount: Double) {
    self.pledgeAmountObserver.send(value: amount)
  }

  private let (shippingRuleSelectedSignal, shippingRuleSelectedObserver) = Signal<ShippingRule, Never>.pipe()
  public func shippingRuleSelected(_ shippingRule: ShippingRule) {
    self.shippingRuleSelectedObserver.send(value: shippingRule)
  }

  private let (traitCollectionDidChangeSignal, traitCollectionDidChangeObserver) = Signal<(), Never>.pipe()
  public func traitCollectionDidChange() {
    self.traitCollectionDidChangeObserver.send(value: ())
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  // MARK: - Outputs

  public let configureSummaryViewControllerWithData: Signal<(Project, Double), Never>
  public let configureWithData: Signal<(project: Project, reward: Reward), Never>
  public let shippingLocationViewHidden: Signal<Bool, Never>
  public let confirmationLabelAttributedText: Signal<NSAttributedString, Never>

  public var inputs: UpdatePledgeViewModelInputs { return self }
  public var outputs: UpdatePledgeViewModelOutputs { return self }
}

private func attributedConfirmationString(with project: Project) -> NSAttributedString? {
  let string = Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_on_project_deadline(
    project_deadline: Format.date(
      secondsInUTC: project.dates.deadline,
      template: "MMMM d, yyyy"
    )
  )

  guard let attributedString = try? NSMutableAttributedString(
    data: Data(string.utf8),
    options: [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: nil
  ) else { return nil }

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center

  let attributes: String.Attributes = [
    .paragraphStyle: paragraphStyle
  ]

  let fullRange = (attributedString.string as NSString).range(of: attributedString.string)

  attributedString.addAttributes(attributes, range: fullRange)

  attributedString.setFontKeepingTraits(
    to: UIFont.ksr_caption1(),
    color: UIColor.ksr_text_dark_grey_500
  )

  return attributedString
}
