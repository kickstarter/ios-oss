import Foundation
import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectEnvironmentalCommitmentDisclaimerCellViewModelInputs {
  /// Call to configure the cell.
  func configure()

  /// Call when a URL in the UITextView is tapped.
  func linkTapped(url: URL)
}

public protocol ProjectEnvironmentalCommitmentDisclaimerCellViewModelOutputs {
  /// Emits an `URL` of the URL being tapped in the UITextView.
  var notifyDelegateLinkTappedWithURL: Signal<URL, Never> { get }
}

public protocol ProjectEnvironmentalCommitmentDisclaimerCellViewModelType {
  var inputs: ProjectEnvironmentalCommitmentDisclaimerCellViewModelInputs { get }
  var outputs: ProjectEnvironmentalCommitmentDisclaimerCellViewModelOutputs { get }
}

public final class ProjectEnvironmentalCommitmentDisclaimerCellViewModel:
  ProjectEnvironmentalCommitmentDisclaimerCellViewModelType,
  ProjectEnvironmentalCommitmentDisclaimerCellViewModelInputs,
  ProjectEnvironmentalCommitmentDisclaimerCellViewModelOutputs {
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

  public var inputs: ProjectEnvironmentalCommitmentDisclaimerCellViewModelInputs { self }
  public var outputs: ProjectEnvironmentalCommitmentDisclaimerCellViewModelOutputs { self }
}
