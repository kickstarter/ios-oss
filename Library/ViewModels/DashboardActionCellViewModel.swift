import KsApi
import ReactiveCocoa
import ReactiveExtensions
import Result

public protocol DashboardActionCellViewModelInputs {
  /// Call when the activity button is tapped.
  func activityTapped()

  /// Call to configure cell with project value.
  func configureWith(project project: Project)

  /// Call when the messages button is tapped.
  func messagesTapped()

  /// Call when the post update button is tapped.
  func postUpdateTapped()

  /// Call when the share button is tapped.
  func shareTapped()
}

public protocol DashboardActionCellViewModelOutputs {
  /// Emits with the project when should go to activity screen.
  var goToActivity: Signal<Project, NoError> { get }

  /// Emits with the project when should go to messages screen.
  var goToMessages: Signal<Project, NoError> { get }

  /// Emits with the project when should go to post update screen.
  var goToPostUpdate: Signal<Project, NoError> { get }

  /// Emits the last update published time to display.
  var lastUpdatePublishedAt: Signal<String, NoError> { get }

  /// Emits with the project when share sheet should be shown.
  var showShareSheet: Signal<Project, NoError> { get }
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

    self.showShareSheet = project.takeWhen(self.shareTappedProperty.signal)

    self.lastUpdatePublishedAt = project
      .map {
        Strings.dashboard_post_update_button_subtitle_last_updated_on_date(
          date: Format.date(
            secondsInUTC: $0.creatorData.lastUpdatePublishedAt ?? 0,
            timeStyle: .NoStyle
          )
        )
    }
  }

  private let activityTappedProperty = MutableProperty()
  public func activityTapped() {
    activityTappedProperty.value = ()
  }

  private let messagesTappedProperty = MutableProperty()
  public func messagesTapped() {
    messagesTappedProperty.value = ()
  }

  private let postUpdateTappedProperty = MutableProperty()
  public func postUpdateTapped() {
    postUpdateTappedProperty.value = ()
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let shareTappedProperty = MutableProperty()
  public func shareTapped() {
    shareTappedProperty.value = ()
  }

  public let goToActivity: Signal<Project, NoError>
  public let goToMessages: Signal<Project, NoError>
  public let goToPostUpdate: Signal<Project, NoError>
  public let lastUpdatePublishedAt: Signal<String, NoError>
  public let showShareSheet: Signal<Project, NoError>

  public var inputs: DashboardActionCellViewModelInputs { return self }
  public var outputs: DashboardActionCellViewModelOutputs { return self }
}
