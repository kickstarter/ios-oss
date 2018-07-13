import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol SettingsPrivacyViewModelInputs{}

public protocol SettingsPrivacyViewModelOutputs{}

public protocol SettingsPrivacyViewModelType {
  var inputs: SettingsPrivacyViewModelInputs { get }
  var outputs: SettingsPrivacyViewModelOutputs { get }
}

public final class SettingsPrivacyViewModel: SettingsPrivacyViewModelType,
SettingsPrivacyViewModelInputs, SettingsPrivacyViewModelOutputs {

  public init(){

  }

  public var inputs: SettingsPrivacyViewModelInputs { return self }
  public var outputs: SettingsPrivacyViewModelOutputs { return self }
}
