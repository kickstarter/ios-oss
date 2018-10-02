import Foundation
import Library
import Prelude

public enum MessageBannerType {
  case success
  case error

  var backgroundColor: UIColor {
    switch self {
    case .success:
      return UIColor.ksr_facebookBlue
    case .error:
      return UIColor.ksr_orange_600
    }
  }
}

final class MessageBannerViewController: UIViewController {
  @IBOutlet fileprivate weak var messageLabel: UILabel!
  @IBOutlet fileprivate weak var backgroundView: UIView!

  private let viewModel: MessageBannerViewModelType = MessageBannerViewModel()

  override func bindStyles() {
    super.bindStyles()

    _ = backgroundView
      |> roundedStyle(cornerRadius: 4)

    _ = messageLabel
      |> UILabel.lens.font .~ .ksr_subhead()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.messageLabel.rac.text = self.viewModel.outputs.bannerMessage
    self.backgroundView.rac.backgroundColor = self.viewModel.outputs.bannerBackgroundColor

    self.viewModel.outputs.messageBannerIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.animateHidden(isHidden)
    }
  }

  func setBannerType(type: MessageBannerType, message: String) {
    self.viewModel.inputs.setBannerType(type: type)
    self.viewModel.inputs.setBannerMessage(message: message)
  }

  func showBannerView() {
    self.viewModel.inputs.setHidden(isHidden: false)
  }

  private func animateHidden(_ isHidden: Bool) {
    // TODO: animate
    self.view.isHidden = isHidden
  }
}
