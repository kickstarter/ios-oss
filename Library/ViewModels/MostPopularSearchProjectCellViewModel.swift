import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol MostPopularSearchProjectCellViewModelInputs {
  func configureWith(project: any BackerDashboardProjectCellViewModel.ProjectCellModel)
}

public protocol MostPopularSearchProjectCellViewModelOutputs {
  /// Emits text for metadata label.
  var metadataText: Signal<String, Never> { get }

  /// Emits the attributed string for the percent funded label.
  var percentFundedText: Signal<NSAttributedString, Never> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, Never> { get }

  /// Emits a color for the progress bar.
  var progressBarColor: Signal<UIColor, Never> { get }

  /// Emits the project's photo URL to be displayed.
  var projectImageUrl: Signal<URL?, Never> { get }

  /// Emits project name to be displayed.
  var projectName: Signal<NSAttributedString, Never> { get }

  /// Emits to hide information about pledging when project is prelaunch
  var prelaunchProject: Signal<Bool, Never> { get }
}

public protocol MostPopularSearchProjectCellViewModelType {
  var inputs: MostPopularSearchProjectCellViewModelInputs { get }
  var outputs: MostPopularSearchProjectCellViewModelOutputs { get }
}

public final class MostPopularSearchProjectCellViewModel: MostPopularSearchProjectCellViewModelType,
  MostPopularSearchProjectCellViewModelInputs, MostPopularSearchProjectCellViewModelOutputs {
  public init() {
    let project = self.projectProperty.signal.skipNil()

    self.projectImageUrl = project.map { URL(string: $0.imageURL) }

    self.projectName = project.map(titleString(for:))

    self.progress = project.map { $0.fundingProgress }

    self.progressBarColor = project.map(progressBarColorForProject)

    self.percentFundedText = project.map(percentFundedString(for:))

    self.metadataText = project.map(metadataString(for:))

    self.prelaunchProject = project.map(isProjectPrelaunch)
  }

  fileprivate let projectProperty =
    MutableProperty<(any BackerDashboardProjectCellViewModel.ProjectCellModel)?>(nil)
  public func configureWith(project: any BackerDashboardProjectCellViewModel.ProjectCellModel) {
    self.projectProperty.value = project
  }

  public let metadataText: Signal<String, Never>
  public let percentFundedText: Signal<NSAttributedString, Never>
  public let progress: Signal<Float, Never>
  public let progressBarColor: Signal<UIColor, Never>
  public let projectImageUrl: Signal<URL?, Never>
  public let projectName: Signal<NSAttributedString, Never>
  public let prelaunchProject: Signal<Bool, Never>

  public var inputs: MostPopularSearchProjectCellViewModelInputs { return self }
  public var outputs: MostPopularSearchProjectCellViewModelOutputs { return self }
}
