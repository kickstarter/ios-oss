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
  var requestExportData: Signal<(), NoError> { get }
  var requestDataDownloadLink: Signal<String, NoError> { get }
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

    self.requestExportData = self.startRequestDataTappedProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.exportData()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }
      .ignoreValues()

    self.requestDataLoadingIndicator = Signal.merge(
      self.configureWithUserProperty.signal.mapConst(false),
      exportEnvelope.map { $0.state == .processing },
      self.startRequestDataTappedProperty.signal.mapConst(true)
    )

    self.requestDataText = self.requestDataLoadingIndicator.signal
      .map { $0 ? Strings.Preparing_your_personal_data() : Strings.Download_your_personal_data() }

    self.requestDataButtonEnabled = self.requestDataLoadingIndicator.signal
      .map { !$0 }

    self.requestDataDownloadLink = exportEnvelope
      .map { $0.dataUrl ?? "" }
      .takeWhen(self.exportDataTappedProperty.signal)
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }

  fileprivate let startRequestDataTappedProperty = MutableProperty(())
  public func startRequestDataTapped() {
    self.startRequestDataTappedProperty.value = ()
  }

  fileprivate let configureWithUserProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithUserProperty.value = user
  }

  public let requestDataText: Signal<String, NoError>
  public let requestDataButtonEnabled: Signal<Bool, NoError>
  public let requestDataLoadingIndicator: Signal<Bool, NoError>
  public let requestExportData: Signal<(), NoError>
  public let requestDataDownloadLink: Signal<String, NoError>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
}
