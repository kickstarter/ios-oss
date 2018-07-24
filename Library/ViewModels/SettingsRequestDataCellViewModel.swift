import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsRequestDataCellViewModelInputs {
  func exportDataTapped()
}

public protocol SettingsRequestDataCellViewModelOutputs {
  var requestExportData: Signal<(), NoError> { get }
}

public protocol SettingsRequestDataCellViewModelType {
  var inputs: SettingsRequestDataCellViewModelInputs { get }
  var outputs: SettingsRequestDataCellViewModelOutputs { get }
}

public final class SettingsRequestDataCellViewModel: SettingsRequestDataCellViewModelType, SettingsRequestDataCellViewModelInputs, SettingsRequestDataCellViewModelOutputs {

  public init() {

    self.requestExportData = self.exportDataTappedProperty.signal
  }

  fileprivate let exportDataTappedProperty = MutableProperty(())
  public func exportDataTapped() {
    self.exportDataTappedProperty.value = ()
  }

  public let requestExportData: Signal<(), NoError>

  public var inputs: SettingsRequestDataCellViewModelInputs { return self }
  public var outputs: SettingsRequestDataCellViewModelOutputs { return self }
}
