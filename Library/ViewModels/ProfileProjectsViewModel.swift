import Foundation
import KsApi
import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result

public enum ProfileProjectsType {
  case backed
  case saved
}

public protocol ProfileProjectsViewModelInputs {
  /// Call to configure with the type of projects to display.
  func configureWith(type: ProfileProjectsType)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProfileProjectsViewModelOutputs {
  /// Emits a boolean that determines if the empty state is visible and a message to display.
  var emptyStateIsVisible: Signal<(Bool, String), NoError> { get }
}

public protocol ProfileProjectsViewModelType {
  var inputs: ProfileProjectsViewModelInputs { get }
  var outputs: ProfileProjectsViewModelOutputs { get }
}

public final class ProfileProjectsViewModel: ProfileProjectsViewModelType, ProfileProjectsViewModelInputs,
  ProfileProjectsViewModelOutputs {

  public init() {
    let projectsType = self.configureWithTypeProperty.signal.skipNil()

    self.emptyStateIsVisible = projectsType
      .map {
        switch $0 {
        case .backed:
          return (true, Strings.profile_projects_empty_state_message())
        case .saved:
          return (true, localizedString(key: "todo", defaultValue: "You haven't saved any projects yet."))
        }
    }
  }

  private let configureWithTypeProperty = MutableProperty<ProfileProjectsType?>(nil)
  public func configureWith(type: ProfileProjectsType) {
    configureWithTypeProperty.value = type
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<(Bool, String), NoError>

  public var inputs: ProfileProjectsViewModelInputs { return self }
  public var outputs: ProfileProjectsViewModelOutputs { return self }
}
