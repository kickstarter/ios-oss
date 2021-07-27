import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol SettingsRequestDataCellViewModelInputs {
  func awakeFromNib()
  func configureWith(user: User)
  func exportDataTapped()
  func startRequestDataTapped()
}

public protocol SettingsRequestDataCellViewModelOutputs {
  var dataExpirationAndChevronHidden: Signal<Bool, Never> { get }
  var goToSafari: Signal<String, Never> { get }
  var requestDataButtonEnabled: Signal<Bool, Never> { get }
  var requestedDataExpirationDate: Signal<String, Never> { get }
  var requestDataLoadingIndicator: Signal<Bool, Never> { get }
  var requestDataText: Signal<String, Never> { get }
  var requestDataTextHidden: Signal<Bool, Never> { get }
  var showPreparingDataAndCheckBackLaterText: Signal<Bool, Never> { get }
  var showRequestDataPrompt: Signal<String, Never> { get }
  var unableToRequestDataError: Signal<String, Never> { get }
}

public protocol SettingsRequestDataCellViewModelType {
  var inputs: SettingsRequestDataCellViewModelInputs { get }
  var outputs: SettingsRequestDataCellViewModelOutputs { get }
}

public final class SettingsRequestDataCellViewModel: SettingsRequestDataCellViewModelType,
  SettingsRequestDataCellViewModelInputs, SettingsRequestDataCellViewModelOutputs {
  public init() {
    let initialUser = Signal.combineLatest(
      self.configureWithUserProperty.signal.skipNil(),
      self.awakeFromNibProperty.signal
    ).map(first)

    let userEmailEvent = self.configureWithUserProperty.signal.skipNil()
      .switchMap { _ in
        AppEnvironment.current.apiService.fetchGraphUser(withStoredCards: true)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    let requestDataAlertText = userEmailEvent.values().map {
      Strings.Youll_receive_an_email_at_email_when_your_download_is_ready(email: $0.me.email ?? "")
    }

    let exportEnvelope = initialUser
      .switchMap { _ in
        AppEnvironment.current.apiService.exportDataState()
          .demoteErrors()
      }

    self.showRequestDataPrompt = Signal.combineLatest(exportEnvelope, requestDataAlertText)
      .filter { canRequestData($0.0) }
      .map { _, alertMessage in alertMessage }
      .takeWhen(self.exportDataTappedProperty.signal.ignoreValues())

    let requestDataEvent = self.startRequestDataTappedProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.exportData()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
      }

    self.unableToRequestDataError = requestDataEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.Unable_to_request()
      }

    self.requestDataLoadingIndicator = Signal.merge(
      self.configureWithUserProperty.signal.mapConst(false),
      exportEnvelope.map { $0.state == .processing },
      self.startRequestDataTappedProperty.signal.mapConst(true)
    )

    let initialText = self.awakeFromNibProperty.signal.mapConst(Strings.Request_my_personal_data())

    self.requestDataText = Signal.merge(
      initialText,
      exportEnvelope
        .map { $0.state == .expired || $0.expiresAt == nil || $0.dataUrl == nil
          ? Strings.Request_my_personal_data() : Strings.Download_your_personal_data()
        }
    )

    self.requestDataButtonEnabled = self.requestDataLoadingIndicator.signal.negate()

    self.requestedDataExpirationDate = exportEnvelope.map {
      dateFormatter(for: $0.expiresAt, state: $0.state)
    }

    self.dataExpirationAndChevronHidden = Signal.merge(
      self.awakeFromNibProperty.signal.mapConst(true),
      exportEnvelope
        .map { $0.state == .expired || $0.expiresAt == nil || $0.dataUrl == nil }
    )

    self.goToSafari = exportEnvelope
      .filter { $0.state != .expired || $0.expiresAt != nil }
      .map { $0.dataUrl ?? "" }
      .takeWhen(self.exportDataTappedProperty.signal)

    self.showPreparingDataAndCheckBackLaterText = Signal.merge(
      self.configureWithUserProperty.signal.mapConst(true),
      exportEnvelope.map { $0.state != .processing },
      self.startRequestDataTappedProperty.signal.mapConst(false)
    )

    self.requestDataTextHidden = self.showPreparingDataAndCheckBackLaterText.signal.map { !$0 }
  }

  fileprivate let awakeFromNibProperty = MutableProperty(())
  public func awakeFromNib() {
    self.awakeFromNibProperty.value = ()
  }

  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }

  fileprivate let startRequestDataTappedProperty = MutableProperty(())
  public func startRequestDataTapped() {
    self.startRequestDataTappedProperty.value = ()
  }

  public let dataExpirationAndChevronHidden: Signal<Bool, Never>
  public let goToSafari: Signal<String, Never>
  public let requestDataButtonEnabled: Signal<Bool, Never>
  public let requestedDataExpirationDate: Signal<String, Never>
  public let requestDataLoadingIndicator: Signal<Bool, Never>
  public let requestDataText: Signal<String, Never>
  public let requestDataTextHidden: Signal<Bool, Never>
  public let showPreparingDataAndCheckBackLaterText: Signal<Bool, Never>
  public let showRequestDataPrompt: Signal<String, Never>
  public let unableToRequestDataError: Signal<String, Never>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
}

private func canRequestData(_ envelope: ExportDataEnvelope) -> Bool {
  return envelope.dataUrl == nil || envelope.state == .expired || envelope.expiresAt == nil
}

private func dateFormatter(for dateString: String?, state: ExportDataEnvelope.State) -> String {
  guard let isoDate = dateString else { return "" }
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sZ"
  guard let date = dateFormatter.date(from: isoDate) else { return "" }

  let expirationDate = Format.date(secondsInUTC: date.timeIntervalSince1970, template: "MMM d, yyyy")
  let expirationTime = Format.date(secondsInUTC: date.timeIntervalSince1970, template: "h:mm a")

  if state == .expired {
    return ""
  } else { return Strings.Expires_date_at_time(date: expirationDate, time: expirationTime) }
}
