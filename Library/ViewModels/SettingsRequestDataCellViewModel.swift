import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsRequestDataCellViewModelInputs {
  func exportDataTapped()
  func startRequestDataTapped()
  func configureWith(user: User)
}

public protocol SettingsRequestDataCellViewModelOutputs {
  var requestDataButtonEnabled: Signal<Bool, NoError> { get }
  var requestDataLoadingIndicator: Signal<Bool, NoError> { get }
  var requestDataText: Signal<String, NoError> { get }
  var showRequestDataPrompt: Signal<(), NoError> { get }
  var unableToRequestDataError: Signal<String, NoError> { get }
  var goToSafari: Signal<String, NoError> { get }
  }

public protocol SettingsRequestDataCellViewModelType {
  var inputs: SettingsRequestDataCellViewModelInputs { get }
  var outputs: SettingsRequestDataCellViewModelOutputs { get }
}

public final class SettingsRequestDataCellViewModel: SettingsRequestDataCellViewModelType, SettingsRequestDataCellViewModelInputs, SettingsRequestDataCellViewModelOutputs {

  public init() {
    let initialUser = configureWithUserProperty.signal
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

    self.requestDataText = self.requestDataLoadingIndicator.signal
      .map { $0 ? Strings.Preparing_your_personal_data() : Strings.Download_your_personal_data() }

    self.requestDataButtonEnabled = self.requestDataLoadingIndicator.signal
      .map { !$0 }

    self.goToSafari = exportEnvelope
      .filter { $0.state != .expired  || $0.expiresAt != nil }
      .map { $0.dataUrl ?? "" }
      .takeWhen(self.exportDataTappedProperty.signal)
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

  public let requestDataText: Signal<String, NoError>
  public let requestDataButtonEnabled: Signal<Bool, NoError>
  public let requestDataLoadingIndicator: Signal<Bool, NoError>
  public let showRequestDataPrompt: Signal<(), NoError>
  public let goToSafari: Signal<String, NoError>
  public let unableToRequestDataError: Signal<String, NoError>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
}
