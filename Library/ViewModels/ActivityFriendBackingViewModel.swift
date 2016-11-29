import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ActivityFriendBackingViewModelInputs {
  /// Call to configure with an Activity.
  func configureWith(activity activity: Activity)
}

public protocol ActivityFriendBackingViewModelOutputs {
  var cellAccessibilityLabel: Signal<String, NoError> { get }
  var cellAccessibilityValue: Signal<String, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var friendImageURL: Signal<NSURL?, NoError> { get }
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

  public init() {
    let activity = self.activityProperty.signal.ignoreNil()
    let project = activity.map { $0.project }.ignoreNil()

    self.friendImageURL = activity
      .map { ($0.user?.avatar.medium).flatMap(NSURL.init) }

    self.friendTitle = activity
      .map { activity in
        guard let categoryId = activity.project?.category.rootId else {
          return NSAttributedString(string: "")
        }

        let title = string(forCategoryId: categoryId, friendName: "<b>\(activity.user?.name ?? "")</b>")
        return title.simpleHtmlAttributedString(
          base: [
            NSFontAttributeName: UIFont.ksr_subhead(size: 14),
            NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
          ],
          bold: [
            NSFontAttributeName: UIFont.ksr_subhead(size: 14),
            NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
          ])
          ?? NSAttributedString(string: "")
    }

    self.fundingBarColor = activity.map {
      return progressBarColor(forActivityCategory: $0.category)
    }

    self.fundingProgressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.percentFundedText = activity
      .map {
        if let project = $0.project {
          let percentage = Format.percentage(project.stats.percentFunded)
          let funded = Strings.percentage_funded(percentage: percentage)

          let fundedAttributedString = NSMutableAttributedString(string: funded, attributes: [
            NSFontAttributeName: UIFont.ksr_caption1(),
            NSForegroundColorAttributeName: UIColor.ksr_navy_500
            ])

          if let percentRange = fundedAttributedString.string.rangeOfString(percentage) {
            let percentStartIndex = fundedAttributedString.string.startIndex.distanceTo(percentRange.startIndex)
            fundedAttributedString.addAttributes([
              NSFontAttributeName: UIFont.ksr_headline(size: 12.0),
              NSForegroundColorAttributeName:
                ($0.category == .cancellation
                  || $0.category == .failure
                  || $0.category == .suspension) ? UIColor.ksr_text_navy_500 : UIColor.ksr_green_500
              ], range: NSRange(location: percentStartIndex, length: percentage.characters.count))
          }

          return fundedAttributedString
        }

        return NSAttributedString(string: "")
    }

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.projectImageURL = activity.map { ($0.project?.photo.med).flatMap(NSURL.init) }

    self.creatorName = activity.map { $0.project?.creator.name ?? "" }

    self.cellAccessibilityLabel = self.friendTitle.map { $0.string }
    self.cellAccessibilityValue = self.projectName
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
  public let creatorName: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>

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
