import Foundation
import KsApi
import ReactiveCocoa
import Result

public protocol ProfileProjectCellViewModelInputs {
  /// Call with a backed project.
  func project(project: Project)
}

public protocol ProfileProjectCellViewModelOutputs {
  /// Emits the project name to be displayed.
  var projectName: Signal<String, NoError> { get }

  /// Emits the project's photo URL to be displayed.
  var photoURL: Signal<NSURL?, NoError> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, NoError> { get }

  /// Emits a boolean that determines if the progress bar should be hidden.
  var progressHidden: Signal<Bool, NoError> { get }

  /// Emits the state of the project to be displayed.
  var state: Signal<String, NoError> { get }

  /// Emits the background color to be displayed for the project's state banner.
  var stateBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits a boolean that determines if the project's state banner should be hidden.
  var stateHidden: Signal<Bool, NoError> { get }
}

public protocol ProfileProjectCellViewModelType {
  var inputs: ProfileProjectCellViewModelInputs { get }
  var outputs: ProfileProjectCellViewModelOutputs { get }
}

public final class ProfileProjectCellViewModel: ProfileProjectCellViewModelType,
  ProfileProjectCellViewModelInputs, ProfileProjectCellViewModelOutputs {
  public init() {
    let project = projectProperty.signal.ignoreNil()

    self.projectName = project.map { $0.name }
    self.photoURL = project.map { NSURL(string: $0.photo.full) }
    self.progress = project.map { $0.stats.fundingProgress }
    self.progressHidden = project.map { $0.state != .live }
    self.state = project.map { $0.state.rawValue }
    self.stateBackgroundColor = project.map {
      $0.state == .successful ? .ksr_green_400 : .ksr_navy_600
    }
    self.stateHidden = project.map { $0.state == .live }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func project(project: Project) {
    self.projectProperty.value = project
  }

  public let projectName: Signal<String, NoError>
  public let photoURL: Signal<NSURL?, NoError>
  public let progress: Signal<Float, NoError>
  public let progressHidden: Signal<Bool, NoError>
  public let state: Signal<String, NoError>
  public let stateBackgroundColor: Signal<UIColor, NoError>
  public let stateHidden: Signal<Bool, NoError>

  public var inputs: ProfileProjectCellViewModelInputs { return self }
  public var outputs: ProfileProjectCellViewModelOutputs { return self }
}
