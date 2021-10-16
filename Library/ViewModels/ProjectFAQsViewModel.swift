import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsViewModelInputs {
  /// Call with the `Project` given to the view.
  func configureWith(project: Project)

  /// Call with the `IndexPath` of the cell selected
  func didSelectRowAt(indexPath: IndexPath)

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectFAQsViewModelOutputs {
  /// Emits the `Project` so the data source can use the faqs and render cells
  var loadFAQs: Signal<Project, Never> { get }
  
  /// Emits the `IndexPath` of the cell that was selected
  var notifyDelegateDidSelectRow: Signal<IndexPath, Never> { get }
}

public protocol ProjectFAQsViewModelType {
  var inputs: ProjectFAQsViewModelInputs { get }
  var outputs: ProjectFAQsViewModelOutputs { get }
}

public final class ProjectFAQsViewModel: ProjectFAQsViewModelType,
  ProjectFAQsViewModelInputs, ProjectFAQsViewModelOutputs {
  public init() {
    let project = self.configureDataProperty.signal
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map(first)

    self.loadFAQs = project
    
    self.notifyDelegateDidSelectRow = self.didSelectRowAtProperty.signal.skipNil()
  }

  fileprivate let configureDataProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.configureDataProperty.value = project
  }

  fileprivate let didSelectRowAtProperty = MutableProperty<IndexPath?>(nil)
  public func didSelectRowAt(indexPath: IndexPath) {
    self.didSelectRowAtProperty.value = indexPath
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadFAQs: Signal<Project, Never>
  public let notifyDelegateDidSelectRow: Signal<IndexPath, Never>

  public var inputs: ProjectFAQsViewModelInputs { return self }
  public var outputs: ProjectFAQsViewModelOutputs { return self }
}
