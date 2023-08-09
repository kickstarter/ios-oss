import Foundation
import KsApi
import Prelude
import ReactiveSwift

public enum ProjectDisclaimerType {
  case environmental
  case aiDisclosure
}

public protocol ProjectTabDisclaimerCellViewModelInputs {
  /// Call to configure the cell with disclaimer type
  func configure(with type: ProjectDisclaimerType)

  /// Call when a URL in the UITextView is tapped.
  func linkTapped(url: URL)
}

public protocol ProjectTabDisclaimerCellViewModelOutputs {
  /// Emits an `URL` of the URL being tapped in the UITextView.
  var notifyDelegateLinkTappedWithURL: Signal<URL, Never> { get }

  /// Emits `ProjectDisclaimerType` to update the UITextView with the correct URL.
  var updateURLFromProjectType: Signal<ProjectDisclaimerType, Never> { get }
}

public protocol ProjectTabDisclaimerCellViewModelType {
  var inputs: ProjectTabDisclaimerCellViewModelInputs { get }
  var outputs: ProjectTabDisclaimerCellViewModelOutputs { get }
}

public final class ProjectTabDisclaimerCellViewModel:
  ProjectTabDisclaimerCellViewModelType,
  ProjectTabDisclaimerCellViewModelInputs,
  ProjectTabDisclaimerCellViewModelOutputs {
  public init() {
    self.notifyDelegateLinkTappedWithURL = self.linkTappedProperty.signal.skipNil()

    self.updateURLFromProjectType = self.configureProperty.signal.skipNil()
  }

  fileprivate let configureProperty = MutableProperty<ProjectDisclaimerType?>(nil)
  public func configure(with type: ProjectDisclaimerType) {
    self.configureProperty.value = type
  }

  fileprivate let linkTappedProperty = MutableProperty<URL?>(nil)
  public func linkTapped(url: URL) {
    self.linkTappedProperty.value = url
  }

  public let notifyDelegateLinkTappedWithURL: Signal<URL, Never>
  public let updateURLFromProjectType: Signal<ProjectDisclaimerType, Never>

  public var inputs: ProjectTabDisclaimerCellViewModelInputs { self }
  public var outputs: ProjectTabDisclaimerCellViewModelOutputs { self }
}
