import Foundation
import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift

public protocol ProjectNotificationsViewModelInputs {
  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectNotificationsViewModelOutputs {
  /// Emits a list of project notifications that should be displayed.
  var projectNotifications: Signal<[ProjectNotification], Never> { get }
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

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let projectNotifications: Signal<[ProjectNotification], Never>

  public var inputs: ProjectNotificationsViewModelInputs { return self }
  public var outputs: ProjectNotificationsViewModelOutputs { return self }
}
