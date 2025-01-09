import Foundation
import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol PledgeOverTimePaymentScheduleViewModelInputs {
  func configure(with increments: [PledgePaymentIncrement], project: Project)
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
      .map { increments, project in
        guard let project = project else { return [] }

        return increments.map { increment in
          PLOTPaymentScheduleItem(with: increment, project: project)
        }
      }
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let configureWithProperty = MutableProperty<([PledgePaymentIncrement], Project?)>(([], nil))
  public func configure(with increments: [PledgePaymentIncrement], project: Project) {
    self.configureWithProperty.value = (increments, project)
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
  public var stateBackgroundColor: UIColor
  public var stateForegroundColor: UIColor
  public var amountAttributedText: NSAttributedString?

  init(with increment: PledgePaymentIncrement, project: Project) {
    self.dateString = Format.date(
      secondsInUTC: increment.scheduledCollection,
      dateStyle: .medium,
      timeStyle: .none
    )

    self.stateLabel = increment.state.description
    self.stateBackgroundColor = increment.state.badgeColor
    self.stateForegroundColor = increment.state.badgeForegroundColor

    self.amountAttributedText = attributedCurrency(
      with: project.country,
      amount: increment.amount.amount,
      omitUSCurrencyCode: project.stats.omitUSCurrencyCode
    )
  }
}

private func attributedCurrency(
  with country: Project.Country,
  amount: Double,
  omitUSCurrencyCode: Bool
) -> NSAttributedString? {
  let defaultAttributes = checkoutCurrencyDefaultAttributes()
    .withAllValuesFrom([.foregroundColor: UIColor.ksr_support_700])
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
