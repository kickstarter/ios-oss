import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsCurrencyCellViewModelInputs {}

public protocol SettingsCurrencyCellViewModelOutputs {}

public protocol SettingsCurrencyCellViewModelType {
  var inputs: SettingsCurrencyCellViewModelInputs { get }
  var outputs: SettingsCurrencyCellViewModelOutputs { get }
}

public final class SettingsCurrencyCellViewModel: SettingsCurrencyCellViewModelType,
SettingsCurrencyCellViewModelInputs, SettingsCurrencyCellViewModelOutputs {

  public init() {

  }

  public var inputs: SettingsCurrencyCellViewModelInputs { return self }
  public var outputs: SettingsCurrencyCellViewModelOutputs { return self }
}
