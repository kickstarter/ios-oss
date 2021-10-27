import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsViewModelInputs {
  /// Call when didSelectRowAt is called on a `ProjectFAQAskAQuestionCell`
  func askAQuestionCellTapped()

  /// Call with the `Project` given to the view.
  func configureWith(project: Project)

  /// Call with the `Int` (index) of the cell selected and the existing values (`[Bool]`) in the data source
  func didSelectRowAt(row: Int, values: [Bool])

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectFAQsViewModelOutputs {
  /// Emits a tuple of `[ProjectFAQ], [Bool]` so the data source can use the faqs and isExpanded states to render cells
  var loadFAQs: Signal<([ProjectFAQ], [Bool]), Never> { get }

  /// Emits `Project` when the MessageDialogViewController should be presented
  var presentMessageDialog: Signal<Project, Never> { get }

  /// Emits a tuple of `[ProjectFAQ], [Bool]` after a cell is selected and the data source needs to be updated
  var updateDataSource: Signal<([ProjectFAQ], [Bool]), Never> { get }
}

public protocol ProjectFAQsViewModelType {
  var inputs: ProjectFAQsViewModelInputs { get }
  var outputs: ProjectFAQsViewModelOutputs { get }
}

public final class ProjectFAQsViewModel: ProjectFAQsViewModelType,
  ProjectFAQsViewModelInputs, ProjectFAQsViewModelOutputs {
  public init() {
    let projectFAQs = self.configureDataProperty.signal
      .map(\ .?.extendedProjectProperties?.faqs)
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map(first)

    let initialIsExpandedArray = projectFAQs
      .map { faqs in Array(repeating: false, count: faqs.count) }

    self.loadFAQs = Signal.combineLatest(projectFAQs, initialIsExpandedArray)

    self.presentMessageDialog = self.configureDataProperty.signal
      .skipNil()
      .takeWhen(self.askAQuestionCellTappedProperty.signal)

    self.updateDataSource = projectFAQs
      .combineLatest(with: self.didSelectRowAtProperty.signal.skipNil())
      .map { projectFAQs, indexAndDataSourceValues in
        let (index, isExpandedValues) = indexAndDataSourceValues
        var updatedValues = isExpandedValues
        updatedValues[index] = !updatedValues[index]

        return (projectFAQs, updatedValues)
      }
  }

  fileprivate let askAQuestionCellTappedProperty = MutableProperty(())
  public func askAQuestionCellTapped() {
    self.askAQuestionCellTappedProperty.value = ()
  }

  fileprivate let configureDataProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.configureDataProperty.value = project
  }

  fileprivate let didSelectRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectRowAt(row: Int, values: [Bool]) {
    self.didSelectRowAtProperty.value = (row, values)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadFAQs: Signal<([ProjectFAQ], [Bool]), Never>
  public let presentMessageDialog: Signal<Project, Never>
  public let updateDataSource: Signal<([ProjectFAQ], [Bool]), Never>

  public var inputs: ProjectFAQsViewModelInputs { return self }
  public var outputs: ProjectFAQsViewModelOutputs { return self }
}
