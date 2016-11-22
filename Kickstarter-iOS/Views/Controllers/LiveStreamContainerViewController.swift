import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class LiveStreamContainerViewController: UIViewController {

  private let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  internal static func configuredWith(project project: Project)
    -> LiveStreamContainerViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController)
      vc.viewModel.inputs.configureWith(project: project)
      return vc
  }
}