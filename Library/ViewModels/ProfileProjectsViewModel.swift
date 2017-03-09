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
  /// Emits a boolean that determines if the empty state is visible and a ProfileProjectsType.
  var emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), NoError> { get }
}

public protocol ProfileProjectsViewModelType {
  var inputs: ProfileProjectsViewModelInputs { get }
  var outputs: ProfileProjectsViewModelOutputs { get }
}

public final class ProfileProjectsViewModel: ProfileProjectsViewModelType, ProfileProjectsViewModelInputs,
  ProfileProjectsViewModelOutputs {

  public init() {
    let projectsType = self.configureWithTypeProperty.signal.skipNil()

    self.emptyStateIsVisible = projectsType.map { (true, $0) }
  }

  private let configureWithTypeProperty = MutableProperty<ProfileProjectsType?>(nil)
  public func configureWith(type: ProfileProjectsType) {
    self.configureWithTypeProperty.value = type
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let emptyStateIsVisible: Signal<(Bool, ProfileProjectsType), NoError>

  public var inputs: ProfileProjectsViewModelInputs { return self }
  public var outputs: ProfileProjectsViewModelOutputs { return self }
}
