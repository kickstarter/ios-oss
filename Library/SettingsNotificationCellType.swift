import KsApi
import UIKit

public enum SettingsNotificationSectionType: Int {
  case backedProjects
  case creator
  case social
  case findFriends

  public var sectionHeaderHeight: CGFloat {
    switch self {
    case .findFriends:
      return Styles.grid(2)
    default:
      return Styles.grid(9)
    }
  }

  public var cellRowsForSection: [SettingsNotificationCellType] {
    switch self {
    case .backedProjects:
      return [.projectUpdates, .projectNotifications]
    case .creator:
      return [.pledgeActivity, .newComments, .newLikes, .creatorTips]
    case .social:
      return [.messages, .newFollowers, .friendBacksProject]
    case .findFriends:
      return [.findFacebookFriends]
    }
  }

  public var sectionTitle: String {
    switch self {
    case .backedProjects:
      return Strings.Projects_youve_backed()
    case .creator:
      return Strings.profile_settings_creator_title()
    case .social:
      return Strings.profile_settings_social_title()
    default:
      return ""
    }
  }

  public static var allCases: [SettingsNotificationSectionType] = [.backedProjects,
                                                                   .creator,
                                                                   .social,
                                                                   .findFriends]
}

public enum SettingsNotificationCellType {
  case projectUpdates
  case projectNotifications
  case pledgeActivity
  case emailFrequency
  case newComments
  case newLikes
  case creatorTips
  case messages
  case newFollowers
  case friendBacksProject
  case findFacebookFriends

  public static var allCases: [SettingsNotificationCellType] = [.projectUpdates,
                                                                .projectNotifications,
                                                                .pledgeActivity,
                                                                .emailFrequency,
                                                                .newComments,
                                                                .newLikes,
                                                                .creatorTips,
                                                                .messages,
                                                                .newFollowers,
                                                                .friendBacksProject,
                                                                .findFacebookFriends]

  public var shouldShowEmailNotificationButton: Bool {
    switch self {
    case .projectNotifications, .findFacebookFriends, .emailFrequency:
      return false
    default:
      return true
    }
  }

  public var showShowPushNotificationButton: Bool {
    switch self {
    case .projectNotifications, .findFacebookFriends, .emailFrequency, .creatorTips:
      return false
    default:
      return true
    }
  }

  public var projectCountLabelHidden: Bool {
    switch self {
    case .projectNotifications: return false
    default: return true
    }
  }

  public var shouldHideArrowView: Bool {
    switch self {
    case .projectNotifications, .findFacebookFriends, .emailFrequency: return false
    default: return true
    }
  }

  public var title: String {
    switch self {
    case .projectUpdates:
      return Strings.profile_settings_backer_project_updates()
    case .projectNotifications:
      return Strings.profile_settings_backer_notifications()
    case .pledgeActivity:
      return Strings.Pledge_activity()
    case .emailFrequency:
      return Strings.Email_frequency()
    case .newComments:
      return Strings.profile_settings_creator_comments()
    case .newLikes:
      return Strings.profile_settings_creator_likes()
    case .creatorTips:
      return Strings.Creator_tips()
    case .messages:
      return Strings.dashboard_buttons_messages()
    case .newFollowers:
      return Strings.profile_settings_social_followers()
    case .friendBacksProject:
      return Strings.profile_settings_social_friend_backs()
    case .findFacebookFriends:
      return Strings.profile_settings_social_find_friends()
    }
  }
}
