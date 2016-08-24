import KsApi
import ReactiveCocoa
import Result

public protocol ActivityFriendBackingViewModelInputs {
  func activity(activity: Activity)
}

public protocol ActivityFriendBackingViewModelOutputs {
  var cellAccessibilityLabel: Signal<String, NoError> { get }
  var cellAccessibilityValue: Signal<String, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var friendImageURL: Signal<NSURL?, NoError> { get }
  var friendTitle: Signal<String, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
}

public protocol ActivityFriendBackingViewModelType {
  var inputs: ActivityFriendBackingViewModelInputs { get }
  var outputs: ActivityFriendBackingViewModelOutputs { get }
}

public final class ActivityFriendBackingViewModel: ActivityFriendBackingViewModelType,
ActivityFriendBackingViewModelInputs, ActivityFriendBackingViewModelOutputs {

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()

    self.friendImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.friendTitle = activity
      .map { activity in
        guard let categoryId = activity.project?.category.rootId else { return "" }
        return string(forCategoryId: categoryId, friendName: activity.user?.name ?? "")
    }

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.projectImageURL = activity.map { ($0.project?.photo.med).flatMap(NSURL.init) }

    self.creatorName = activity.map { $0.project?.creator.name ?? "" }

    self.cellAccessibilityLabel = self.friendTitle
    self.cellAccessibilityValue = self.projectName
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func activity(activity: Activity) {
    self.activityProperty.value = activity
  }

  public let friendImageURL: Signal<NSURL?, NoError>
  public let friendTitle: Signal<String, NoError>
  public let projectName: Signal<String, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let creatorName: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>

  public var inputs: ActivityFriendBackingViewModelInputs { return self }
  public var outputs: ActivityFriendBackingViewModelOutputs { return self }
}

// swiftlint:disable cyclomatic_complexity
private func string(forCategoryId id: Int, friendName: String) -> String {
  let root = RootCategory(categoryId: id)
  switch root {
  case .art:          return Strings.activity_friend_backed_art_project(friend_name: friendName)
  case .comics:       return Strings.activity_friend_backed_comics_project(friend_name: friendName)
  case .dance:        return Strings.activity_friend_backed_dance_project(friend_name: friendName)
  case .design:       return Strings.activity_friend_backed_design_project(friend_name: friendName)
  case .fashion:      return Strings.activity_friend_backed_fashion_project(friend_name: friendName)
  case .food:         return Strings.activity_friend_backed_food_project(friend_name: friendName)
  case .film:         return Strings.activity_friend_backed_film_project(friend_name: friendName)
  case .games:        return Strings.activity_friend_backed_games_project(friend_name: friendName)
  case .journalism:   return Strings.activity_friend_backed_journalism_project(friend_name: friendName)
  case .music:        return Strings.activity_friend_backed_music_project(friend_name: friendName)
  case .photography:  return Strings.activity_friend_backed_photography_project(friend_name: friendName)
  case .tech:         return Strings.activity_friend_backed_tech_project(friend_name: friendName)
  case .theater:      return Strings.activity_friend_backed_theater_project(friend_name: friendName)
  case .publishing:   return Strings.activity_friend_backed_publishing_project(friend_name: friendName)
  case .crafts:       return Strings.activity_friend_backed_crafts_project(friend_name: friendName)
  case .unrecognized: return ""
  }
}
// swiftlint:enable cyclomatic_complexity
