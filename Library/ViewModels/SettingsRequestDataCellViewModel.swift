import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsRequestDataCellViewModelInputs {
  func exportDataTapped()
  func configureWith(user: User)
}

public protocol SettingsRequestDataCellViewModelOutputs {
  var requestDataButtonEnabled: Signal<Bool, NoError> { get }
  var requestDataLoadingIndicator: Signal<Bool, NoError> { get }
  var requestDataText: Signal<String, NoError> { get }
  var requestExportData: Signal<(), NoError> { get }
}

public protocol SettingsRequestDataCellViewModelType {
  var inputs: SettingsRequestDataCellViewModelInputs { get }
  var outputs: SettingsRequestDataCellViewModelOutputs { get }
}

public final class SettingsRequestDataCellViewModel: SettingsRequestDataCellViewModelType, SettingsRequestDataCellViewModelInputs, SettingsRequestDataCellViewModelOutputs {

  public init() {
    let initialUser = configureWithProperty.signal
      .skipNil()

    self.requestExportData = self.exportDataTappedProperty.signal
      .switchMap {
        AppEnvironment.current.apiService.exportData()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }
      .ignoreValues()

    let exportEnvelope = initialUser
      .switchMap { _ in
        AppEnvironment.current.apiService.exportDataState()
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
    }

    self.requestDataLoadingIndicator = Signal.merge(
    //  self.viewDidLoadProperty.signal.mapConst(false),
      exportEnvelope.map { $0.state == .processing },
      self.exportDataTappedProperty.signal.mapConst(true)
    )

    self.requestDataText = self.requestDataLoadingIndicator.signal
      .map { $0 ? Strings.Preparing_your_personal_data() : Strings.Download_your_personal_data() }

    self.requestDataButtonEnabled = self.requestDataLoadingIndicator.signal
      .map { !$0 }

// In Expiration Footer
//    self.exportDataExpirationDate = exportEnvelope
//      .map { dateFormatter(for: $0.expiresAt, state: $0.state) }
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }

  fileprivate let configureWithProperty = MutableProperty<User?>(nil)
  public func configureWith(user: User) {
    self.configureWithProperty.value = user
  }

  public let requestDataText: Signal<String, NoError>
  public let requestDataButtonEnabled: Signal<Bool, NoError>
  public let requestDataLoadingIndicator: Signal<Bool, NoError>
  public let requestExportData: Signal<(), NoError>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
}
