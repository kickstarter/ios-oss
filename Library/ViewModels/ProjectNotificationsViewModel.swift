import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public protocol ProjectNotificationsViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectNotificationsViewModelOutputs {
  /// Emits a list of project notifications that should be displayed.
  var projectNotifications: Signal<[ProjectNotification], NoError> { get }
}

public protocol ProjectNotificationsViewModelType {
  var inputs: ProjectNotificationsViewModelInputs { get }
  var outputs: ProjectNotificationsViewModelOutputs { get }
}

public final class ProjectNotificationsViewModel: ProjectNotificationsViewModelType,
  ProjectNotificationsViewModelInputs, ProjectNotificationsViewModelOutputs {
  public init() {

    self.projectNotifications = self.viewDidLoadProperty.signal
      .flatMap {
        AppEnvironment.current.apiService.fetchProjectNotifications()
          .demoteErrors()
    }


  }

  fileprivate let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let projectNotifications: Signal<[ProjectNotification], NoError>

  public var inputs: ProjectNotificationsViewModelInputs { return self }
  public var outputs: ProjectNotificationsViewModelOutputs { return self }
}
