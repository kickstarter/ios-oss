import Foundation
import KDS
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol PledgeOverTimePaymentScheduleViewModelInputs {
  func configure(with increments: [PledgePaymentIncrement])
  func collapseToggle()
  func viewDidLoad()
}

public protocol PledgeOverTimePaymentScheduleViewModelOutputs {
  var collapsed: Signal<Bool, Never> { get }
  var paymentScheduleItems: Signal<[PLOTPaymentScheduleItem], Never> { get }
}

public protocol PledgeOverTimePaymentScheduleViewModelType {
  var inputs: PledgeOverTimePaymentScheduleViewModelInputs { get }
  var outputs: PledgeOverTimePaymentScheduleViewModelOutputs { get }
}

public struct PledgeOverTimePaymentScheduleViewModel: PledgeOverTimePaymentScheduleViewModelType,
  PledgeOverTimePaymentScheduleViewModelInputs, PledgeOverTimePaymentScheduleViewModelOutputs {
  public init() {
    let configureWith = Signal.combineLatest(
      self.configureWithProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let initialCollapsed = Signal.combineLatest(
      self.collapsedProperty.signal,
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.collapsed = initialCollapsed

    self.paymentScheduleItems = configureWith
      .map { increments in
        increments.map { increment in
          PLOTPaymentScheduleItem(with: increment)
        }
      }
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let configureWithProperty = MutableProperty<[PledgePaymentIncrement]>([])
  public func configure(with increments: [PledgePaymentIncrement]) {
    self.configureWithProperty.value = increments
  }

  private let collapsedProperty = MutableProperty<Bool>(true)
  public func collapseToggle() {
    self.collapsedProperty.value = !self.collapsedProperty.value
  }

  public var collapsed: Signal<Bool, Never>
  public var paymentScheduleItems: Signal<[PLOTPaymentScheduleItem], Never>

  public var inputs: PledgeOverTimePaymentScheduleViewModelInputs { self }
  public var outputs: PledgeOverTimePaymentScheduleViewModelOutputs { self }
}

// MARK: - PLOTPaymentScheduleItem

public struct PLOTPaymentScheduleItem: Equatable {
  public var dateString: String
  public var stateLabel: String
  public var badgeStyle: BadgeStyle
  public var amountString: String

  init(with increment: PledgePaymentIncrement) {
    self.dateString = Format.date(
      secondsInUTC: increment.scheduledCollection,
      dateStyle: .medium,
      timeStyle: .none
    )

    self.amountString = getAmountString(from: increment)
    self.stateLabel = getStateLabelText(from: increment)
    self.badgeStyle = getBadgeStyle(from: increment)
  }
}

private func getAmountString(from increment: PledgePaymentIncrement) -> String {
  // Only display the adjusted amount if a partial refund was issued.
  // If the payment increment was fully refunded, display the full payment increment amount.
  if case let .partialRefund(refundedAmount) = increment.refundStatus {
    return refundedAmount.amountFormattedInProjectNativeCurrency
  }

  return increment.amount.amountFormattedInProjectNativeCurrency
}

private func getStateLabelText(from increment: PledgePaymentIncrement) -> String {
  guard let badge = increment.badge else {
    assert(false, "Missing badge when it should have been fetched.")
    return ""
  }

  return badge.copy
}

private func getBadgeStyle(from increment: PledgePaymentIncrement) -> BadgeStyle {
  guard let badge = increment.badge else {
    assert(false, "Missing badge when it should have been fetched.")
    return .neutral
  }

  switch badge.variant {
  case .purple:
    return .custom(
      foregroundColor: Colors.PLOT.Badge.Text.purple.uiColor(),
      backgroundColor: Colors.PLOT.Badge.Background.purple.uiColor()
    )
  case .green:
    return .custom(
      foregroundColor: Colors.PLOT.Badge.Text.green.uiColor(),
      backgroundColor: Colors.PLOT.Badge.Background.green.uiColor()
    )
  case .red:
    // TODO: This variant isn't implemented on the backend; I believe it's a bug and should actually be danger.
    fallthrough
  case .danger:
    return BadgeStyle.custom(
      foregroundColor: Colors.PLOT.Badge.Text.danger.uiColor(),
      backgroundColor: Colors.PLOT.Badge.Background.danger.uiColor()
    )
  case .gray:
    return .custom(
      foregroundColor: Colors.PLOT.Badge.Text.gray.uiColor(),
      backgroundColor: Colors.PLOT.Badge.Background.gray.uiColor()
    )
  }
}
