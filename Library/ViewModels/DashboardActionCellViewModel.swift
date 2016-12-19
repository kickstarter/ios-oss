import KsApi
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol DashboardActionCellViewModelInputs {
  /// Call when the activity button is tapped.
  func activityTapped()

  /// Call to configure cell with project value.
  func configureWith(project: Project)

  /// Call when the messages button is tapped.
  func messagesTapped()

  /// Call when the post update button is tapped.
  func postUpdateTapped()
}

public protocol DashboardActionCellViewModelOutputs {
  /// Emits the activity button label and unseen activities count to be read by voiceover.
  var activityButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the activity row is hidden.
  var activityRowHidden: Signal<Bool, NoError> { get }

  /// Emits with the project when should go to activity screen.
  var goToActivity: Signal<Project, NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<Project, NoError> { get }

  /// Emits with the project when should go to post update screen.
  var goToPostUpdate: Signal<Project, NoError> { get }

  /// Emits the last update published time to display.
  var lastUpdatePublishedAt: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the last update published label should be hidden.
  var lastUpdatePublishedLabelHidden: Signal<Bool, NoError> { get }

  /// Emits the messages button label and unread messages count to be read by voiceover.
  var messagesButtonAccessibilityLabel: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the messages row should be hidden.
  var messagesRowHidden: Signal<Bool, NoError> { get }

  /// Emits a boolean that determines if the post update button should be hidden
  var postUpdateButtonHidden: Signal<Bool, NoError> { get }

  /// Emits the last update published at value to be read by voiceover.
  var postUpdateButtonAccessibilityValue: Signal<String, NoError> { get }

  /// Emits the count of unread messages to be displayed.
  var unreadMessagesCount: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the unread messages indicator should be hidden.
  var unreadMessagesCountHidden: Signal<Bool, NoError> { get }

  /// Emits the count of unseen activities to be displayed.
  var unseenActivitiesCount: Signal<String, NoError> { get }

  /// Emits a boolean that determines if the unseen activities indicator should be hidden.
  var unseenActivitiesCountHidden: Signal<Bool, NoError> { get }
}

public protocol DashboardActionCellViewModelType {
  var inputs: DashboardActionCellViewModelInputs { get }
  var outputs: DashboardActionCellViewModelOutputs { get }
}

public final class DashboardActionCellViewModel: DashboardActionCellViewModelInputs,
  DashboardActionCellViewModelOutputs, DashboardActionCellViewModelType {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.goToActivity = project.takeWhen(self.activityTappedProperty.signal)

    self.goToMessages = project.takeWhen(self.messagesTappedProperty.signal)

    self.goToPostUpdate = project.takeWhen(self.postUpdateTappedProperty.signal)

    self.lastUpdatePublishedAt = project
      .map { project in
        if let lastUpdatePublishedAt = project.memberData.lastUpdatePublishedAt {
          return Strings.dashboard_post_update_button_subtitle_last_updated_on_date(
            date: Format.date(secondsInUTC: lastUpdatePublishedAt, timeStyle: .NoStyle)
          )
        }

        if .Some(project.creator) == AppEnvironment.current.currentUser {
          return Strings.dashboard_post_update_button_subtitle_you_have_not_posted_an_update_yet()
        } else {
          return localizedString(
            key: "No_one_has_posted_an_update_yet", defaultValue: "No one has posted an update yet."
          )
        }
    }

    self.postUpdateButtonAccessibilityValue = self.lastUpdatePublishedAt

    self.unreadMessagesCount = project.map { Format.wholeNumber($0.memberData.unreadMessagesCount ?? 0) }
    self.unreadMessagesCountHidden = project.map { ($0.memberData.unreadMessagesCount ?? 0) == 0 }
    self.unseenActivitiesCount = project.map { Format.wholeNumber($0.memberData.unseenActivityCount ?? 0) }
    self.unseenActivitiesCountHidden = project.map { ($0.memberData.unseenActivityCount ?? 0) == 0 }

    self.activityButtonAccessibilityLabel = self.unseenActivitiesCount
      .map {
        Strings.activity_navigation_title_activity() + ", " + $0 + " unseen"
    }

    self.messagesButtonAccessibilityLabel = self.unreadMessagesCount
      .map {
        Strings.profile_buttons_messages() + ", " + $0 + " unread"
    }

    self.lastUpdatePublishedLabelHidden = project.map { !$0.memberData.permissions.contains(.post) }
    self.postUpdateButtonHidden = self.lastUpdatePublishedLabelHidden

    self.messagesRowHidden = project.map { $0.creator != AppEnvironment.current.currentUser }

    self.activityRowHidden = project.map { !$0.memberData.permissions.contains(.viewPledges) }
  }

  fileprivate let activityTappedProperty = MutableProperty()
  public func activityTapped() {
    activityTappedProperty.value = ()
  }

  fileprivate let messagesTappedProperty = MutableProperty()
  public func messagesTapped() {
    messagesTappedProperty.value = ()
  }

  fileprivate let postUpdateTappedProperty = MutableProperty()
  public func postUpdateTapped() {
    postUpdateTappedProperty.value = ()
  }

  fileprivate let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.projectProperty.value = project
  }

  public let activityButtonAccessibilityLabel: Signal<String, NoError>
  public let activityRowHidden: Signal<Bool, NoError>
  public let goToActivity: Signal<Project, NoError>
  public let goToMessages: Signal<Project, NoError>
  public let goToPostUpdate: Signal<Project, NoError>
  public let lastUpdatePublishedAt: Signal<String, NoError>
  public let lastUpdatePublishedLabelHidden: Signal<Bool, NoError>
  public let messagesButtonAccessibilityLabel: Signal<String, NoError>
  public let messagesRowHidden: Signal<Bool, NoError>
  public let postUpdateButtonAccessibilityValue: Signal<String, NoError>
  public let postUpdateButtonHidden: Signal<Bool, NoError>
  public let unreadMessagesCount: Signal<String, NoError>
  public let unreadMessagesCountHidden: Signal<Bool, NoError>
  public let unseenActivitiesCount: Signal<String, NoError>
  public let unseenActivitiesCountHidden: Signal<Bool, NoError>

  public var inputs: DashboardActionCellViewModelInputs { return self }
  public var outputs: DashboardActionCellViewModelOutputs { return self }
}
