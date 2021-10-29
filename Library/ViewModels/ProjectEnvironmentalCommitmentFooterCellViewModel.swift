import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelInputs {
  /// Call to configure the cell.
  func configure()

  /// Call when a URL in the UITextView is tapped.
  func linkTapped(url: URL)
}

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelOutputs {
  /// Emits an `URL` of the URL being tapped in the UITextView.
  var notifyDelegateLinkTappedWithURL: Signal<URL, Never> { get }
}

public protocol ProjectEnvironmentalCommitmentFooterCellViewModelType {
  var inputs: ProjectEnvironmentalCommitmentFooterCellViewModelInputs { get }
  var outputs: ProjectEnvironmentalCommitmentFooterCellViewModelOutputs { get }
}

public final class ProjectEnvironmentalCommitmentFooterCellViewModel:
  ProjectEnvironmentalCommitmentFooterCellViewModelType,
  ProjectEnvironmentalCommitmentFooterCellViewModelInputs,
  ProjectEnvironmentalCommitmentFooterCellViewModelOutputs {
  public init() {
    self.notifyDelegateLinkTappedWithURL = self.linkTappedProperty.signal.skipNil()
  }

  fileprivate let configureProperty = MutableProperty(())
  public func configure() {
    self.configureProperty.value = ()
  }

  fileprivate let linkTappedProperty = MutableProperty<URL?>(nil)
  public func linkTapped(url: URL) {
    self.linkTappedProperty.value = url
  }

  public let notifyDelegateLinkTappedWithURL: Signal<URL, Never>

  public var inputs: ProjectEnvironmentalCommitmentFooterCellViewModelInputs { self }
  public var outputs: ProjectEnvironmentalCommitmentFooterCellViewModelOutputs { self }
}
