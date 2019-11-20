import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol EditorialProjectViewModelInputs {
  func configure(with project: Project)
}

public protocol EditorialProjectViewModelOutputs {
  var labelText: Signal<NSAttributedString, Never> { get }
}

public protocol EditorialProjectViewModelType {
  var inputs: EditorialProjectViewModelInputs { get }
  var outputs: EditorialProjectViewModelOutputs { get }
}

public class EditorialProjectViewModel: EditorialProjectViewModelType,
  EditorialProjectViewModelInputs, EditorialProjectViewModelOutputs {
  public init() {
    let project = self.configureWithProjectProperty.signal.skipNil()

    self.labelText = .empty
  }

  private let configureWithProjectProperty = MutableProperty<Project?>(nil)
  public func configure(with project: Project) {
    self.configureWithProjectProperty.value = project
  }

  public let labelText: Signal<NSAttributedString, Never>

  public var inputs: EditorialProjectViewModelInputs { return self }
  public var outputs: EditorialProjectViewModelOutputs { return self }
}
