import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct ManageViewPledgeRewardReceivedViewData: Equatable {
  public let project: Project
  public let backerCompleted: Bool
  public let estimatedDeliveryOn: TimeInterval
  public let backingState: Backing.Status
}

public protocol ManageViewPledgeRewardReceivedViewModelInputs {
  func configureWith(_ data: ManageViewPledgeRewardReceivedViewData)
  func rewardReceivedToggleTapped(isOn: Bool)
  func viewDidLoad()
}

public protocol ManageViewPledgeRewardReceivedViewModelOutputs {
  var cornerRadius: Signal<CGFloat, Never> { get }
  var estimatedDeliveryDateLabelAttributedText: Signal<NSAttributedString, Never> { get }
  var layoutMargins: Signal<UIEdgeInsets, Never> { get }
  var marginWidth: Signal<CGFloat, Never> { get }
  var rewardReceived: Signal<Bool, Never> { get }
  var rewardReceivedHidden: Signal<Bool, Never> { get }
}

public protocol ManageViewPledgeRewardReceivedViewModelType {
  var inputs: ManageViewPledgeRewardReceivedViewModelInputs { get }
  var outputs: ManageViewPledgeRewardReceivedViewModelOutputs { get }
}

public class ManageViewPledgeRewardReceivedViewModel:
  ManageViewPledgeRewardReceivedViewModelType,
  ManageViewPledgeRewardReceivedViewModelInputs,
  ManageViewPledgeRewardReceivedViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.configureWithDataProperty.signal,
      self.viewDidLoadSignal
    )
    .map(first)
    .skipNil()

    let project = data.map(\.project)

    let backer = project
      .map { _ in AppEnvironment.current.currentUser }
      .skipNil()

    let rewardReceivedEvent = Signal.combineLatest(
      project,
      backer
    )
    .takePairWhen(self.rewardReceivedToggleTappedProperty.signal)
    .map(unpack)
    .switchMap { project, backer, received in
      AppEnvironment.current.apiService.backingUpdate(
        forProject: project, forUser: backer, received: received
      )
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .materialize()
    }

    let markedReceivedBacking = rewardReceivedEvent.values()

    let initialRewardReceived = data
      .map(\.backerCompleted)

    let updatedRewardReceived = markedReceivedBacking
      .map { $0.backerCompleted.coalesceWith(false) }

    self.rewardReceived = Signal.merge(
      initialRewardReceived,
      updatedRewardReceived
    )

    self.estimatedDeliveryDateLabelAttributedText = data.map(\.estimatedDeliveryOn)
      .map(estimatedDeliveryAttributedText)

    self.rewardReceivedHidden = data.map(\.backingState).map { state in state != .collected }
    self.cornerRadius = self.rewardReceivedHidden.map { $0 ? 0 : Styles.grid(2) }
    self.layoutMargins = self.rewardReceivedHidden.map { $0 ? .zero : .init(all: Styles.gridHalf(5)) }
    self.marginWidth = self.rewardReceivedHidden.map { $0 ? 0 : 1 }
  }

  private let configureWithDataProperty = MutableProperty<ManageViewPledgeRewardReceivedViewData?>(nil)
  public func configureWith(_ data: ManageViewPledgeRewardReceivedViewData) {
    self.configureWithDataProperty.value = data
  }

  private let rewardReceivedToggleTappedProperty = MutableProperty<Bool>(false)
  public func rewardReceivedToggleTapped(isOn: Bool) {
    self.rewardReceivedToggleTappedProperty.value = isOn
  }

  private let (viewDidLoadSignal, viewDidLoadObserver) = Signal<(), Never>.pipe()
  public func viewDidLoad() {
    self.viewDidLoadObserver.send(value: ())
  }

  public let cornerRadius: Signal<CGFloat, Never>
  public let estimatedDeliveryDateLabelAttributedText: Signal<NSAttributedString, Never>
  public let layoutMargins: Signal<UIEdgeInsets, Never>
  public let marginWidth: Signal<CGFloat, Never>
  public let rewardReceived: Signal<Bool, Never>
  public let rewardReceivedHidden: Signal<Bool, Never>

  public var inputs: ManageViewPledgeRewardReceivedViewModelInputs { return self }
  public var outputs: ManageViewPledgeRewardReceivedViewModelOutputs { return self }
}

private func estimatedDeliveryAttributedText(with date: TimeInterval) -> NSAttributedString {
  let dateString = Format.date(
    secondsInUTC: date,
    template: DateFormatter.monthYear,
    timeZone: UTCTimeZone
  )
  let string = Strings.backing_info_estimated_delivery_date(delivery_date: dateString)

  let font = UIFont.ksr_subhead()

  let attributedText = NSMutableAttributedString(attributedString: string
    .attributed(
      with: font,
      foregroundColor: .ksr_support_400,
      attributes: [:],
      bolding: [string.replacingOccurrences(of: dateString, with: "")]
    ))

  attributedText.setAttributes(
    [
      .font: font,
      .foregroundColor: UIColor.ksr_support_700
    ],
    range: (string as NSString).range(of: dateString)
  )

  return attributedText
}
