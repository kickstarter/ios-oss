import KsApi
import UIKit

public struct SettingsNotificationCellValue {
  public let cellType: SettingsNotificationCellType
  public let user: User

  public init(cellType: SettingsNotificationCellType, user: User) {
    self.cellType = cellType
    self.user = user
  }
}

public enum SettingsNotificationSectionType: Int, CaseIterable {
  case announcements
  case backedProjects
  case creator
  case social

  public var sectionHeaderHeight: CGFloat {
    return Styles.grid(9)
  }

  public var cellRowsForSection: [SettingsNotificationCellType] {
    switch self {
    case .announcements:
      return [.marketingUpdate]
    case .backedProjects:
      return [.projectUpdates, .projectNotifications]
    case .creator:
      return [.pledgeActivity, .newComments, .newLikes, .creatorTips]
    case .social:
      return [.messages, .newFollowers, .friendBacksProject, .commentReplyDigest]
    }
  }

  public var sectionTitle: String {
    switch self {
    case .announcements:
      return Strings.Announcements()
    case .backedProjects:
      return Strings.Projects_youve_backed()
    case .creator:
      return Strings.Projects_youve_launched()
    case .social:
      return Strings.profile_settings_social_title()
    }
  }
}

public enum SettingsNotificationCellType: CaseIterable {
  case projectUpdates
  case projectNotifications
  case pledgeActivity
  case emailFrequency
  case newComments
  case newLikes
  case creatorTips
  case marketingUpdate
  case messages
  case newFollowers
  case friendBacksProject
  case commentReplyDigest

  public var accessibilityTraits: UIAccessibilityTraits {
    switch self {
    case .projectNotifications, .emailFrequency:
      return .button
    default:
      return .none
    }
  }

  public var accessibilityElementsHidden: Bool {
    switch self {
    case .projectNotifications:
      return false
    default:
      return true
    }
  }

  public var shouldShowEmailNotificationButton: Bool {
    switch self {
    case .projectNotifications, .emailFrequency, .newLikes, .marketingUpdate:
      return false
    default:
      return true
    }
  }

  public var shouldShowPushNotificationButton: Bool {
    switch self {
    case .projectNotifications, .emailFrequency, .creatorTips, .commentReplyDigest:
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
    case .projectNotifications, .emailFrequency: return false
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
      return Strings.Project_activity()
    case .emailFrequency:
      return Strings.Email_frequency()
    case .newComments:
      return Strings.profile_settings_creator_comments()
    case .newLikes:
      return Strings.profile_settings_creator_likes()
    case .creatorTips:
      return Strings.Creator_tips()
    case .marketingUpdate:
      return Strings.Chosen_just_for_you()
    case .messages:
      return Strings.dashboard_buttons_messages()
    case .newFollowers:
      return Strings.profile_settings_social_followers()
    case .friendBacksProject:
      return Strings.profile_settings_social_friend_backs()
    case .commentReplyDigest:
      return Strings.Comment_reply_digest()
    }
  }
}
