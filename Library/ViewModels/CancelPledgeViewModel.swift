import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct CancelPledgeViewData {
  public let project: Project // TODO: remove once tracking is updated.
  public let projectCountry: Project.Country
  public let projectName: String
  public let omitUSCurrencyCode: Bool
  public let backingId: String
  public let pledgeAmount: Double
}

public protocol CancelPledgeViewModelInputs {
  func cancelPledgeButtonTapped()
  func configure(with data: CancelPledgeViewData)
  func goBackButtonTapped()
  func textFieldDidEndEditing(with text: String?)
  func textFieldShouldReturn()
  func traitCollectionDidChange()
  func viewDidLoad()
  func viewTapped()
}

public protocol CancelPledgeViewModelOutputs {
  var cancellationDetailsAttributedText: Signal<NSAttributedString, Never> { get }
  var cancelPledgeButtonEnabled: Signal<Bool, Never> { get }
  var cancelPledgeError: Signal<String, Never> { get }
  var dismissKeyboard: Signal<Void, Never> { get }
  var notifyDelegateCancelPledgeSuccess: Signal<String, Never> { get }
  var popCancelPledgeViewController: Signal<Void, Never> { get }
}

public protocol CancelPledgeViewModelType {
  var inputs: CancelPledgeViewModelInputs { get }
  var outputs: CancelPledgeViewModelOutputs { get }
}

public final class CancelPledgeViewModel: CancelPledgeViewModelType, CancelPledgeViewModelInputs,
  CancelPledgeViewModelOutputs {
  public init() {
    let data = Signal.combineLatest(
      self.configureWithDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    self.cancellationDetailsAttributedText = Signal.merge(
      data,
      data.takeWhen(self.traitCollectionDidChangeProperty.signal)
    )
    .map { data in
      let formattedAmount = Format.currency(
        data.pledgeAmount,
        country: data.projectCountry,
        omitCurrencyCode: data.omitUSCurrencyCode
      )
      return (formattedAmount, data.projectName)
    }
    .map(createCancellationDetailsAttributedText(with:projectName:))

    self.popCancelPledgeViewController = self.goBackButtonTappedProperty.signal

    self.dismissKeyboard = Signal.merge(
      self.textFieldShouldReturnProperty.signal,
      self.viewTappedProperty.signal
    )

    let cancellationNote = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(nil),
      self.textFieldDidEndEditingTextProperty.signal
    )

    let cancelPledgeSubmit = Signal.combineLatest(
      data.map { $0.backingId },
      cancellationNote
    )
    .takeWhen(self.cancelPledgeButtonTappedProperty.signal)

    let cancelPledgeEvent = cancelPledgeSubmit
      .map(CancelBackingInput.init(backingId:cancellationReason:))
      .switchMap { input in
        AppEnvironment.current.apiService.cancelBacking(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.notifyDelegateCancelPledgeSuccess = cancelPledgeEvent.values()
      .map { _ in Strings.Youve_canceled_your_pledge() }

    self.cancelPledgeError = cancelPledgeEvent
      .errors()
      .map { $0.localizedDescription }

    self.cancelPledgeButtonEnabled = Signal.merge(
      data.mapConst(true),
      cancelPledgeSubmit.mapConst(false),
      cancelPledgeEvent.map { $0.isTerminating }.mapConst(true)
    )
    .skipRepeats()

    // Tracking
    data
      .takeWhen(self.cancelPledgeButtonTappedProperty.signal)
      .map { ($0.project, $0.pledgeAmount) }
      .observeValues { project, amount in
        AppEnvironment.current.koala.trackCancelPledgeButtonClicked(
          project: project,
          backingAmount: amount
        )
      }
  }

  private let cancelPledgeButtonTappedProperty = MutableProperty(())
  public func cancelPledgeButtonTapped() {
    self.cancelPledgeButtonTappedProperty.value = ()
  }

  private let configureWithDataProperty = MutableProperty<CancelPledgeViewData?>(nil)
  public func configure(with data: CancelPledgeViewData) {
    self.configureWithDataProperty.value = data
  }

  private let goBackButtonTappedProperty = MutableProperty(())
  public func goBackButtonTapped() {
    self.goBackButtonTappedProperty.value = ()
  }

  private let textFieldDidEndEditingTextProperty = MutableProperty<String?>(nil)
  public func textFieldDidEndEditing(with text: String?) {
    self.textFieldDidEndEditingTextProperty.value = text
  }

  private let textFieldShouldReturnProperty = MutableProperty(())
  public func textFieldShouldReturn() {
    self.textFieldShouldReturnProperty.value = ()
  }

  private let traitCollectionDidChangeProperty = MutableProperty(())
  public func traitCollectionDidChange() {
    self.traitCollectionDidChangeProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewTappedProperty = MutableProperty(())
  public func viewTapped() {
    self.viewTappedProperty.value = ()
  }

  public let cancellationDetailsAttributedText: Signal<NSAttributedString, Never>
  public let cancelPledgeButtonEnabled: Signal<Bool, Never>
  public let cancelPledgeError: Signal<String, Never>
  public let dismissKeyboard: Signal<Void, Never>
  public let notifyDelegateCancelPledgeSuccess: Signal<String, Never>
  public let popCancelPledgeViewController: Signal<Void, Never>

  public var inputs: CancelPledgeViewModelInputs { return self }
  public var outputs: CancelPledgeViewModelOutputs { return self }
}

private func createCancellationDetailsAttributedText(with amount: String, projectName: String)
  -> NSAttributedString {
  let fullString = Strings
    .Are_you_sure_you_wish_to_cancel_your_amount_pledge_to_project_name(
      amount: amount,
      project_name: projectName
    )
  let attributedString: NSMutableAttributedString = NSMutableAttributedString.init(string: fullString)
  let regularFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_callout()]
  let boldFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_callout().bolded]
  let fullRange = (fullString as NSString).localizedStandardRange(of: fullString)
  let rangeAmount: NSRange = (fullString as NSString).localizedStandardRange(of: amount)
  let rangeProjectName: NSRange = (fullString as NSString).localizedStandardRange(of: projectName)

  attributedString.addAttributes(regularFontAttribute, range: fullRange)
  attributedString.addAttributes(boldFontAttribute, range: rangeAmount)
  attributedString.addAttributes(boldFontAttribute, range: rangeProjectName)

  return attributedString
}
