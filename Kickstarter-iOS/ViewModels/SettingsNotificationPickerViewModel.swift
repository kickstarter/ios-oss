import KsApi
import Library
import Prelude
import ReactiveSwift
import Result

public enum EmailFrequency: Int {
  case daily
  case individualEmails

  public static let allCases: [EmailFrequency] = [.daily, .individualEmails]

  var descriptionText: String {
    switch self {
    case .daily:
      return Strings.Daily_digest()
    case .individualEmails:
      return Strings.Individual_Emails()
    }
  }
}

protocol SettingsNotificationPickerViewModelOutputs {
  var frequencyValueText: Signal<String, NoError> { get }
  var unableToSaveError: Signal<String, NoError> { get }
  var updateCurrentUser: Signal<User, NoError> { get }
}

protocol SettingsNotificationPickerViewModelInputs {
  func configure(with cellValue: SettingsNotificationCellValue)
  func frequencyValueSelected(frequency: EmailFrequency)
}

protocol SettingsNotificationPickerViewModelType {
  var inputs: SettingsNotificationPickerViewModelInputs { get }
  var outputs: SettingsNotificationPickerViewModelOutputs { get }
}

final class SettingsNotificationPickerViewModel: SettingsNotificationPickerViewModelOutputs, SettingsNotificationPickerViewModelInputs,
SettingsNotificationPickerViewModelType {

  init() {
    let initialUser = initialUserProperty.signal.skipNil()

    let userDefinedEmailFrequency = initialUser.signal
      .map { user in
        user |> UserAttribute.notification(.creatorDigest).lens.view
      }.skipNil()
      .map { creatorDigestEnabled in
        return creatorDigestEnabled ? EmailFrequency.daily : EmailFrequency.individualEmails
      }

    let userAttributeChanged = frequencyValueProperty.signal
      .map { frequency -> (UserAttribute, Bool) in
        let digestValue = frequency == .daily ? true : false

        return (UserAttribute.notification(.creatorDigest), digestValue)
    }

    let updatedUser = initialUser.signal
      .switchMap { user in
        userAttributeChanged.scan(user) { user, attributeAndOn in
          let (attribute, on) = attributeAndOn
          return user |> attribute.lens .~ on
        }
    }

    let updateEvent = updatedUser
      .switchMap {
        AppEnvironment.current.apiService.updateUserSelf($0)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .materialize()
    }

    self.unableToSaveError = updateEvent.errors()
      .map { env in
        env.errorMessages.first ?? Strings.profile_settings_error()
    }

    self.updateCurrentUser = updateEvent.values()

    let initialFrequencyValue = userDefinedEmailFrequency.signal
      .take(first: 1)

    let previousFrequencyValue = initialFrequencyValue.takeWhen(self.unableToSaveError)

    self.frequencyValueText = Signal.merge(
      frequencyValueProperty.signal,
      userDefinedEmailFrequency.signal,
      previousFrequencyValue.signal
      ).map { $0.descriptionText }
  }

  fileprivate var initialUserProperty = MutableProperty<User?>(nil)
  func configure(with cellValue: SettingsNotificationCellValue) {
    self.initialUserProperty.value = cellValue.user
  }

  fileprivate var frequencyValueProperty = MutableProperty<EmailFrequency>(EmailFrequency.individualEmails)
  func frequencyValueSelected(frequency: EmailFrequency) {
    self.frequencyValueProperty.value = frequency
  }

  public let frequencyValueText: Signal<String, NoError>
  public let unableToSaveError: Signal<String, NoError>
  public let updateCurrentUser: Signal<User, NoError>

  var outputs: SettingsNotificationPickerViewModelOutputs {
    return self
  }

  var inputs: SettingsNotificationPickerViewModelInputs {
    return self
  }
}
