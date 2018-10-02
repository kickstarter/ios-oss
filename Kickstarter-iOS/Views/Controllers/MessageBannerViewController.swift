import Foundation
import Library
import Prelude

public enum MessageBannerType {
  case success
  case error

  var backgroundColor: UIColor {
    switch self {
    case .success:
      return UIColor.ksr_azure_blue
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

    self.viewModel.outputs.messageBannerViewShouldShow
      .observeForUI()
      .observeValues { [weak self] _ in
        self?.showViewAndAnimate()
    }
  }

  func setBannerType(type: MessageBannerType, message: String) {
    self.viewModel.inputs.setBannerType(type: type)
    self.viewModel.inputs.setBannerMessage(message: message)
  }

  func showBannerView() {
    self.viewModel.inputs.showBannerView()
  }

  private func showViewAndAnimate() {
    self.view.alpha = 0.0
    self.view.isHidden = false

    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      self?.view.alpha = 1.0
      },
    completion: { (_) in
      UIView.animate(withDuration: 0.3, delay: 3.0, options: [], animations: { [weak self] in
        self?.view.alpha = 0.0
      }, completion: nil)
    })
  }
}
