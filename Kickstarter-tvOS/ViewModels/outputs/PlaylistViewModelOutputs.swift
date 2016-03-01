import ReactiveCocoa
import Result
import Models

internal protocol PlaylistViewModelOutputs {
  /// Emits when a new project should be transitioned too
  var project: SignalProducer<Project, NoError> { get }

  /// Emits a category name when the label on the screen should change.
  var categoryName: SignalProducer<String, NoError> { get }

  /// Emits a project name when the label on the screen should change.
  var projectName: SignalProducer<String, NoError> { get }

  /// Emits an image to be displayed in the background.
  var backgroundImage: SignalProducer<UIImage?, NoError> { get }
}
