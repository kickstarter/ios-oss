import KsApi
import Prelude
import ReactiveSwift

public protocol ActivityFriendBackingViewModelInputs {
  /// Call to configure with an Activity.
  func configureWith(activity: Activity)
}

public protocol ActivityFriendBackingViewModelOutputs {
  /// Emits an a11y label for the cell.
  var cellAccessibilityLabel: Signal<String, Never> { get }

  /// Emits an URL for the friend avatar image view.
  var friendImageURL: Signal<URL?, Never> { get }

  /// Emits an attributed string for the "friend backed" label.
  var friendTitle: Signal<NSAttributedString, Never> { get }

  /// Emits a color for the funding progress bar.
  var fundingBarColor: Signal<UIColor, Never> { get }

  /// Emits a percentage between 0.0 and 1.0 that can be used to render the funding progress bar.
  var fundingProgressPercentage: Signal<Float, Never> { get }

  /// Emits an attributed string for percent funded label.
  var percentFundedText: Signal<NSAttributedString, Never> { get }

  /// Emits a url to the project image.
  var projectImageURL: Signal<URL?, Never> { get }

  /// Emits text for the project name label.
  var projectName: Signal<String, Never> { get }
}

public protocol ActivityFriendBackingViewModelType {
  var inputs: ActivityFriendBackingViewModelInputs { get }
  var outputs: ActivityFriendBackingViewModelOutputs { get }
}

public final class ActivityFriendBackingViewModel: ActivityFriendBackingViewModelType,
  ActivityFriendBackingViewModelInputs, ActivityFriendBackingViewModelOutputs {
  public init() {
    let activity = self.activityProperty.signal.skipNil()
    let project = activity.map { $0.project }.skipNil()

    self.friendImageURL = activity
      .map { ($0.user?.avatar.small).flatMap(URL.init) }

    self.friendTitle = activity
      .map { activity in
        let stringCategoryId = (
          activity.project?.category.parentId ?? activity.project?.category.id
        )
        .map(String.init)

        guard let categoryId = stringCategoryId else {
          return NSAttributedString(string: "")
        }

        let title = string(forCategoryId: categoryId, friendName: activity.user?.name ?? "")
        return title.simpleHtmlAttributedString(
          base: [
            NSAttributedString.Key.font: UIFont.ksr_subhead(size: 12),
            NSAttributedString.Key.foregroundColor: UIColor.ksr_text_dark_grey_500
          ],
          bold: [
            NSAttributedString.Key.font: UIFont.ksr_subhead(size: 12),
            NSAttributedString.Key.foregroundColor: UIColor.ksr_soft_black
          ],
          italic: [
            NSAttributedString.Key.font: UIFont.ksr_subhead(size: 12),
            NSAttributedString.Key.foregroundColor: UIColor.ksr_soft_black
          ]
        )
          ?? .init()
      }

    self.fundingBarColor = activity.map { progressBarColor(forActivityCategory: $0.category) }

    self.fundingProgressPercentage = project
      .map(Project.lens.stats.fundingProgress.view)
      .map(clamp(0, 1))

    self.percentFundedText = activity.map(percentFundedString(forActivity:))

    self.projectName = activity.map { $0.project?.name ?? "" }

    self.projectImageURL = activity.map { ($0.project?.photo.full).flatMap(URL.init) }

    self.cellAccessibilityLabel = Signal.combineLatest(self.friendTitle, self.projectName)
      .map { "\($0.string), \($1)" }
  }

  fileprivate let activityProperty = MutableProperty<Activity?>(nil)
  public func configureWith(activity: Activity) {
    self.activityProperty.value = activity
  }

  public let friendImageURL: Signal<URL?, Never>
  public let friendTitle: Signal<NSAttributedString, Never>
  public let fundingBarColor: Signal<UIColor, Never>
  public let fundingProgressPercentage: Signal<Float, Never>
  public let percentFundedText: Signal<NSAttributedString, Never>
  public let projectName: Signal<String, Never>
  public let projectImageURL: Signal<URL?, Never>
  public let cellAccessibilityLabel: Signal<String, Never>

  public var inputs: ActivityFriendBackingViewModelInputs { return self }
  public var outputs: ActivityFriendBackingViewModelOutputs { return self }
}

private func progressBarColor(forActivityCategory category: Activity.Category) -> UIColor {
  switch category {
  case .cancellation, .failure, .suspension:
    return .ksr_dark_grey_400
  case .launch, .success:
    return .ksr_green_700
  default:
    return .ksr_green_700
  }
}

private func string(forCategoryId id: String, friendName: String) -> String {
  let root = RootCategory(categoryId: Int(id) ?? -1)
  switch root {
  case .art: return Strings.Friend_backed_art_project(friend_name: friendName)
  case .comics: return Strings.Friend_backed_comics_project(friend_name: friendName)
  case .dance: return Strings.Friend_backed_dance_project(friend_name: friendName)
  case .design: return Strings.Friend_backed_design_project(friend_name: friendName)
  case .fashion: return Strings.Friend_backed_fashion_project(friend_name: friendName)
  case .food: return Strings.Friend_backed_food_project(friend_name: friendName)
  case .film: return Strings.Friend_backed_film_project(friend_name: friendName)
  case .games: return Strings.Friend_backed_games_project(friend_name: friendName)
  case .journalism: return Strings.Friend_backed_journalism_project(friend_name: friendName)
  case .music: return Strings.Friend_backed_music_project(friend_name: friendName)
  case .photography: return Strings.Friend_backed_photography_project(friend_name: friendName)
  case .tech: return Strings.Friend_backed_tech_project(friend_name: friendName)
  case .theater: return Strings.Friend_backed_theater_project(friend_name: friendName)
  case .publishing: return Strings.Friend_backed_publishing_project(friend_name: friendName)
  case .crafts: return Strings.Friend_backed_crafts_project(friend_name: friendName)
  case .unrecognized: return ""
  }
}

private func percentFundedString(forActivity activity: Activity) -> NSAttributedString {
  guard let project = activity.project else { return NSAttributedString(string: "") }

  let percentage = Format.percentage(project.stats.percentFunded)

  return NSAttributedString(string: percentage, attributes: [
    NSAttributedString.Key.font: UIFont.ksr_caption1(size: 10),
    NSAttributedString.Key.foregroundColor: UIColor.ksr_green_700
  ])
}
