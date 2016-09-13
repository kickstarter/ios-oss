import KsApi
import Prelude
import ReactiveCocoa
import Result

public protocol ProjectFooterViewModelInputs {
  /// Call with the project given to the controller.
  func configureWith(project project: Project)

  /// Call when the contact creator button is tapped.
  func contactCreatorButtonTapped()

  func creatorButtonTapped()

  /// Call when the "keep reading" button is tapped.
  func keepReadingButtonTapped()

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectFooterViewModelOutputs {
  /// Emits the text for the creator's backed projects label.
  var backedProjectsLabelText: Signal<String, NoError> { get }

  /// Emits the title for the category label.
  var categoryButtonTitle: Signal<String, NoError> { get }

  /// Emits the text for the creator's created projects label.
  var createdProjectsLabelText: Signal<String, NoError> { get }

  /// Emits the creator's avatar image url.
  var creatorImageUrl: Signal<NSURL?, NoError> { get }

  /// Emits the text for the creator's name label.
  var creatorNameLabelText: Signal<String, NoError> { get }

  var goToCreatorBio: Signal<Project, NoError> { get }

  /// Emits a project when we should go to the message creator screen.
  var goToMessageCreator: Signal<Project, NoError> { get }

  /// Emits a boolean that determines if the keep reading button should be hidden.
  var keepReadingHidden: Signal<Bool, NoError> { get }

  /// Emits the title of the location button.
  var locationButtonTitle: Signal<String, NoError> { get }

  /// Emits when the delegate should be notified to expand the description.
  var notifyDelegateToExpandDescription: Signal<(), NoError> { get }

  /// Emits the text for the creator's updates label.
  var updatesLabelText: Signal<String, NoError> { get }
}

public protocol ProjectFooterViewModelType {
  var inputs: ProjectFooterViewModelInputs { get }
  var outputs: ProjectFooterViewModelOutputs { get }
}

public final class ProjectFooterViewModel: ProjectFooterViewModelType, ProjectFooterViewModelInputs,
ProjectFooterViewModelOutputs {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.keepReadingHidden = Signal.merge(
      self.viewDidLoadProperty.signal.mapConst(false),
      self.keepReadingButtonTappedProperty.signal.mapConst(true)
      )
      .skipRepeats()

    self.notifyDelegateToExpandDescription = self.keepReadingHidden
      .filter(isTrue)
      .ignoreValues()

    self.backedProjectsLabelText = project.map {
      Strings.social_following_friend_projects_count_backed(
        backed_count: $0.creator.stats.backedProjectsCount ?? 0
      )
    }

    self.createdProjectsLabelText = project
      .map { $0.creator.stats.createdProjectsCount ?? 0 }
      .map {
        $0 <= 1
          ? Strings.First_created()
          : Strings.social_following_friend_projects_count_created(created_count: $0)
    }

    self.creatorNameLabelText = project.map(Project.lens.creator.name.view)

    self.updatesLabelText = project
      .map { Strings.updates_count_updates(updates_count: Format.wholeNumber($0.stats.updatesCount ?? 0))}

    self.creatorImageUrl = project.map { NSURL(string: $0.creator.avatar.medium) }

    self.categoryButtonTitle = project.map(Project.lens.category.name.view)
    self.locationButtonTitle = project.map(Project.lens.location.displayableName.view)

    self.goToMessageCreator = project
      .takeWhen(self.contactCreatorButtonTappedProperty.signal)

    self.goToCreatorBio = project
      .takeWhen(self.creatorButtonTappedProperty.signal)
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func configureWith(project project: Project) {
    self.projectProperty.value = project
  }

  private let contactCreatorButtonTappedProperty = MutableProperty()
  public func contactCreatorButtonTapped() {
    self.contactCreatorButtonTappedProperty.value = ()
  }

  private let creatorButtonTappedProperty = MutableProperty()
  public func creatorButtonTapped() {
    self.creatorButtonTappedProperty.value = ()
  }

  private let keepReadingButtonTappedProperty = MutableProperty()
  public func keepReadingButtonTapped() {
    self.keepReadingButtonTappedProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty()
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let backedProjectsLabelText: Signal<String, NoError>
  public let categoryButtonTitle: Signal<String, NoError>
  public let createdProjectsLabelText: Signal<String, NoError>
  public let creatorImageUrl: Signal<NSURL?, NoError>
  public let creatorNameLabelText: Signal<String, NoError>
  public let goToCreatorBio: Signal<Project, NoError>
  public let goToMessageCreator: Signal<Project, NoError>
  public let keepReadingHidden: Signal<Bool, NoError>
  public let locationButtonTitle: Signal<String, NoError>
  public let notifyDelegateToExpandDescription: Signal<(), NoError>
  public let updatesLabelText: Signal<String, NoError>

  public var inputs: ProjectFooterViewModelInputs { return self }
  public var outputs: ProjectFooterViewModelOutputs { return self }
}
