import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ActivityFriendBackingViewModelInputs {
  /// Call to configure with an Activity.
  func configureWith(activity activity: Activity)
}

public protocol ActivityFriendBackingViewModelOutputs {
  /// Emits an a11y label for the cell.
  var cellAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits an NSURL for the friend avatar image view.
  var friendImageURL: Signal<NSURL?, NoError> { get }

  /// Emits an attributed string for the "friend backed" label.
  var friendTitle: Signal<NSAttributedString, NoError> { get }

  /// Emits a color for the funding progress bar.
  var fundingBarColor: Signal<UIColor, NoError> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var fundingProgressPercentage: Signal<Float, NoError> { get }

  /// Emits an attributed string for percent funded label.
  var percentFundedText: Signal<NSAttributedString, NoError> { get }

  /// Emits a url to the project image.
  var projectImageURL: Signal<NSURL?, NoError> { get }

  /// Emits text for the project name label.
  var projectName: Signal<String, NoError> { get }
}

public protocol ActivityFriendBackingViewModelType {
  var inputs: ActivityFriendBackingViewModelInputs { get }
  var outputs: ActivityFriendBackingViewModelOutputs { get }
}

public final class ActivityFriendBackingViewModel: ActivityFriendBackingViewModelType,
ActivityFriendBackingViewModelInputs, ActivityFriendBackingViewModelOutputs {

  // swiftlint:disable:next function_body_length
  public init() {
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.friendImageURL = activity
      .map { ($0.user?.avatar.small).flatMap(NSURL.init) }

    self.friendTitle = activity
      .map { activity in
        guard let categoryId = activity.project?.category.rootId else {
          return NSAttributedString(string: "")
        }

        let title = string(forCategoryId: categoryId, friendName: activity.user?.name ?? "")
        return title.simpleHtmlAttributedString(
          base: [
            NSFontAttributeName: UIFont.ksr_subhead(size: 14),
            NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
          ],
          bold: [
            NSFontAttributeName: UIFont.ksr_subhead(size: 14),
            NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
          ],
          italic: [
            NSFontAttributeName: UIFont.ksr_subhead(size: 14),
            NSForegroundColorAttributeName: color(forCategoryId: categoryId)
          ])
          ?? NSAttributedString(string: "")
    }

    self.fundingBarColor = activity.map { progressBarColor(forActivityCategory: $0.category) }

    self.fundingProgressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.percentFundedText = activity.map(percentFundedString(forActivity:))

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.projectImageURL = activity.map { ($0.project?.photo.full).flatMap(NSURL.init) }

    self.cellAccessibilityLabel = combineLatest(self.friendTitle, self.projectName)
      .map { "\($0.string), \($1)" }
  }

  private let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity activity: Activity) {
    self.activityProperty.value = activity
  }

  public let friendImageURL: Signal<NSURL?, NoError>
  public let friendTitle: Signal<NSAttributedString, NoError>
  public let fundingBarColor: Signal<UIColor, NoError>
  public let fundingProgressPercentage: Signal<Float, NoError>
  public let percentFundedText: Signal<NSAttributedString, NoError>
  public let projectName: Signal<String, NoError>
  public let projectImageURL: Signal<NSURL?, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>

  public var inputs: ActivityFriendBackingViewModelInputs { return self }
  public var outputs: ActivityFriendBackingViewModelOutputs { return self }
}

private func progressBarColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return .ksr_navy_500
  case .launch, .success:
    return .ksr_green_400
  default:
    return .ksr_green_400
  }
}

public func color(forCategoryId id: Int?) -> UIColor {
  let group = CategoryGroup(categoryId: id)
  switch group {
  case .none:
    return .ksr_navy_700
  case .culture:
    return .ksr_red_400
  case .entertainment:
    return .ksr_violet_500
  case .story:
    return .ksr_forest_600
  }
}

// swiftlint:disable cyclomatic_complexity
private func string(forCategoryId id: Int, friendName: String) -> String {
  let root = RootCategory(categoryId: id)
  switch root {
  case .art:          return Strings.Friend_backed_art_project(friend_name: friendName)
  case .comics:       return Strings.Friend_backed_comics_project(friend_name: friendName)
  case .dance:        return Strings.Friend_backed_dance_project(friend_name: friendName)
  case .design:       return Strings.Friend_backed_design_project(friend_name: friendName)
  case .fashion:      return Strings.Friend_backed_fashion_project(friend_name: friendName)
  case .food:         return Strings.Friend_backed_food_project(friend_name: friendName)
  case .film:         return Strings.Friend_backed_film_project(friend_name: friendName)
  case .games:        return Strings.Friend_backed_games_project(friend_name: friendName)
  case .journalism:   return Strings.Friend_backed_journalism_project(friend_name: friendName)
  case .music:        return Strings.Friend_backed_music_project(friend_name: friendName)
  case .photography:  return Strings.Friend_backed_photography_project(friend_name: friendName)
  case .tech:         return Strings.Friend_backed_tech_project(friend_name: friendName)
  case .theater:      return Strings.Friend_backed_theater_project(friend_name: friendName)
  case .publishing:   return Strings.Friend_backed_publishing_project(friend_name: friendName)
  case .crafts:       return Strings.Friend_backed_crafts_project(friend_name: friendName)
  case .unrecognized: return ""
  }
}
// swiftlint:enable cyclomatic_complexity

private func percentFundedString(forActivity activity: Activity) -> NSAttributedString {
  guard let project = activity.project else { return NSAttributedString(string: "") }

  let percentage = Format.percentage(project.stats.percentFunded)
  let funded = Strings.percentage_funded(percentage: percentage)

  let mutableString = NSMutableAttributedString(string: funded, attributes: [
    NSFontAttributeName: UIFont.ksr_caption1(),
    NSForegroundColorAttributeName: UIColor.ksr_navy_500
    ])

  if let percentRange = mutableString.string.rangeOfString(percentage) {
    let percentStartIndex = mutableString.string.startIndex.distanceTo(percentRange.startIndex)
    mutableString.addAttributes([
      NSFontAttributeName: UIFont.ksr_headline(size: 12.0),
      NSForegroundColorAttributeName:
        (activity.category == .cancellation
          || activity.category == .failure
          || activity.category == .suspension) ? UIColor.ksr_text_navy_500 : UIColor.ksr_green_500
      ], range: NSRange(location: percentStartIndex, length: percentage.characters.count))
  }

  return mutableString
}
