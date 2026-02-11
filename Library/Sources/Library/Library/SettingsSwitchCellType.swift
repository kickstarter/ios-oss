import Foundation

public enum SettingsStaticCellType {
  case following
  case recommendations

  public var description: String {
    switch self {
    case .following:
      return Strings.When_following_is_on_you_can_follow_the_acticity_of_others()
    case .recommendations:
      return Strings.We_use_your_activity_internally_to_make_recommendations_for_you()
    }
  }
}

public enum SettingsSwitchCellType {
  case privacy

  public var title: String {
    return Strings.Private_profile()
  }

  public var primaryDescription: String {
    return Strings.If_your_profile_is_private()
  }

  public var secondaryDescription: String {
    return Strings.If_your_profile_is_public()
  }
}
