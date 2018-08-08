import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsRequestDataCellViewModelInputs {
  func configureWith(user: User)
  func exportDataTapped()
  func startRequestDataTapped()
}

public protocol SettingsRequestDataCellViewModelOutputs {
  var dataExpirationAndChevronHidden: Signal<Bool, NoError> { get }
  var goToSafari: Signal<String, NoError> { get }
  var requestDataButtonEnabled: Signal<Bool, NoError> { get }
  var requestedDataExpirationDate: Signal<String, NoError> { get }
  var requestDataLoadingIndicator: Signal<Bool, NoError> { get }
  var requestDataText: Signal<String, NoError> { get }
  var requestDataTextHidden: Signal<Bool, NoError> { get }
  var showPreparingDataText: Signal<Bool, NoError> { get }
  var showRequestDataPrompt: Signal<(), NoError> { get }
  var unableToRequestDataError: Signal<String, NoError> { get }
}

public protocol SettingsRequestDataCellViewModelType {
  var inputs: SettingsRequestDataCellViewModelInputs { get }
  var outputs: SettingsRequestDataCellViewModelOutputs { get }
}

public final class SettingsRequestDataCellViewModel: SettingsRequestDataCellViewModelType,
  SettingsRequestDataCellViewModelInputs, SettingsRequestDataCellViewModelOutputs {

  public init() {
    let initialUser = self.configureWithUserProperty.signal
      .skipNil()

    let exportEnvelope = initialUser
      .switchMap { _ in
        AppEnvironment.current.apiService.exportDataState()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    self.showRequestDataPrompt = exportEnvelope
      .takeWhen(self.exportDataTappedProperty.signal.ignoreValues())
      .filter { $0.dataUrl == nil || $0.state == .expired || $0.expiresAt == nil }
      .ignoreValues()

    let requestDataEvent = self.startRequestDataTappedProperty.signal
      .switchMap { _ in
        AppEnvironment.current.apiService.exportData()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.unableToRequestDataError = requestDataEvent.errors()
      .map { env in
        env.errorMessages.first ?? "unable to request data"
    }

    self.requestDataLoadingIndicator = Signal.merge(
      self.configureWithUserProperty.signal.mapConst(false),
      exportEnvelope.map { $0.state == .processing },
      self.startRequestDataTappedProperty.signal.mapConst(true)
    )

    self.requestDataText = exportEnvelope
      .map { $0.state == .expired || $0.expiresAt == nil || $0.dataUrl == nil
        ? Strings.Request_my_Personal_Data() : Strings.Download_your_personal_data() }

    self.requestDataButtonEnabled = self.requestDataLoadingIndicator.signal
      .map { !$0 }

    self.requestedDataExpirationDate = exportEnvelope.map {
        dateFormatter(for: $0.expiresAt, state: $0.state)
      }

    self.dataExpirationAndChevronHidden = exportEnvelope
      .map { $0.state == .expired || $0.expiresAt == nil || $0.dataUrl == nil ? true : false }

    self.goToSafari = exportEnvelope
      .filter { $0.state != .expired  || $0.expiresAt != nil }
      .map { $0.dataUrl ?? "" }
      .takeWhen(self.exportDataTappedProperty.signal)

    self.showPreparingDataText = Signal.merge(
      self.configureWithUserProperty.signal.mapConst(true),
      exportEnvelope.map { $0.state != .processing },
      self.startRequestDataTappedProperty.signal.mapConst(false)
    )

    self.requestDataTextHidden = self.showPreparingDataText.signal.map { !$0 }
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }
  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }
  fileprivate let startRequestDataTappedProperty = MutableProperty(())
  public func startRequestDataTapped() {
    self.startRequestDataTappedProperty.value = ()
  }

  public let dataExpirationAndChevronHidden: Signal<Bool, NoError>
  public let goToSafari: Signal<String, NoError>
  public let requestDataButtonEnabled: Signal<Bool, NoError>
  public let requestedDataExpirationDate: Signal<String, NoError>
  public let requestDataLoadingIndicator: Signal<Bool, NoError>
  public let requestDataText: Signal<String, NoError>
  public let requestDataTextHidden: Signal<Bool, NoError>
  public let showPreparingDataText: Signal<Bool, NoError>
  public let showRequestDataPrompt: Signal<(), NoError>
  public let unableToRequestDataError: Signal<String, NoError>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
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
