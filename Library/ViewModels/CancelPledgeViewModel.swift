import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol CancelPledgeViewModelInputs {
  func cancelPledgeButtonTapped()
  func configure(with project: Project, backing: Backing)
  func goBackButtonTapped()
  func textFieldDidEndEditing(with text: String?)
  func textFieldShouldReturn()
  func traitCollectionDidChange()
  func viewDidLoad()
}

public protocol CancelPledgeViewModelOutputs {
  var cancellationDetailsAttributedText: Signal<NSAttributedString, Never> { get }
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
    let initialData = Signal.combineLatest(
      self.configureWithProjectAndBackingProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let backing = initialData
      .map(second)

    self.cancellationDetailsAttributedText = Signal.merge(
      initialData,
      initialData.takeWhen(self.traitCollectionDidChangeProperty.signal)
    )
    .map { project, backing in
      let formattedAmount = Format.currency(
        backing.amount,
        country: project.country,
        omitCurrencyCode: project.stats.omitUSCurrencyCode
      )
      return (formattedAmount, project.name)
    }
    .map(createCancellationDetailsAttributedText(with:projectName:))

    self.popCancelPledgeViewController = self.goBackButtonTappedProperty.signal

    self.dismissKeyboard = self.textFieldShouldReturnProperty.signal

    let cancellationNote = Signal.merge(self.viewDidLoadProperty.signal.mapConst(nil),
                                        self.textFieldDidEndEditingTextProperty.signal)

    let cancelPledgeEvent = Signal.combineLatest(backing.map { $0.graphID },
                                                 cancellationNote)
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
  }

  private let cancelPledgeButtonTappedProperty = MutableProperty(())
  public func cancelPledgeButtonTapped() {
    self.cancelPledgeButtonTappedProperty.value = ()
  }

  private let configureWithProjectAndBackingProperty = MutableProperty<(Project, Backing)?>(nil)
  public func configure(with project: Project, backing: Backing) {
    self.configureWithProjectAndBackingProperty.value = (project, backing)
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

  public let cancellationDetailsAttributedText: Signal<NSAttributedString, Never>
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
