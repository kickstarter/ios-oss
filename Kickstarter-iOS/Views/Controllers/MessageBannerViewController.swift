import Foundation
import Library
import Prelude

final class MessageBannerViewController: UIViewController {
  @IBOutlet fileprivate weak var backgroundView: UIView!
  @IBOutlet fileprivate weak var backgroundViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var iconImageView: UIImageView!
  @IBOutlet fileprivate weak var messageLabel: UILabel!

  private var bottomMarginConstraintConstant: CGFloat = -Styles.grid(1)

  private let viewModel: MessageBannerViewModelType = MessageBannerViewModel()

  struct AnimationConstants {
    static let hideDuration: TimeInterval = 0.25
    static let showDuration: TimeInterval = 0.3
  }

  override func bindStyles() {
    super.bindStyles()

    _ = backgroundView
      |> roundedStyle(cornerRadius: 4)

    _ = messageLabel
      |> UILabel.lens.font .~ .ksr_subhead()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.iconImageView.rac.hidden = self.viewModel.outputs.iconIsHidden
    self.backgroundView.rac.backgroundColor = self.viewModel.outputs.bannerBackgroundColor
    self.messageLabel.rac.text = self.viewModel.outputs.bannerMessage
    self.messageLabel.rac.textColor = self.viewModel.outputs.messageTextColor

    self.viewModel.outputs.messageBannerViewIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.showViewAndAnimate(isHidden)
    }

    self.viewModel.outputs.iconImage
      .observeForUI()
      .observeValues { [weak self] image in
        guard let `self` = self else { return }
        _ = self.iconImageView
          |> UIImageView.lens.image .~ image
    }

    self.viewModel.outputs.messageTextAlignment
      .observeForUI()
      .observeValues { [weak self] textAlignment in
        guard let `self` = self else { return }

        _ = self.messageLabel
         |> UILabel.lens.textAlignment .~ textAlignment
    }
  }

  func showBanner(with type: MessageBannerType, message: String) {
    self.viewModel.inputs.setBannerType(type: type)
    self.viewModel.inputs.setBannerMessage(message: message)
    self.viewModel.inputs.showBannerView(shouldShow: true)
  }

  private func showViewAndAnimate(_ isHidden: Bool) {
    let duration = isHidden ? AnimationConstants.hideDuration : AnimationConstants.showDuration

    if !isHidden {
      self.view.isHidden = isHidden
    }

    UIView.animate(withDuration: duration, delay: 0.0,
                   options: UIView.AnimationOptions.curveEaseInOut,
                   animations: { [weak self] in
                    guard let `self` = self else { return }
                    let frameHeight = self.view.frame.size.height
                    self.backgroundViewBottomConstraint.constant = isHidden
                      ? frameHeight : self.bottomMarginConstraintConstant
                    self.view.layoutIfNeeded()
    }, completion: { [weak self] _ in
        self?.view.isHidden = isHidden

        self?.viewModel.inputs.bannerViewAnimationFinished(isHidden: isHidden)
    })
  }

  @IBAction private func bannerViewPanned(_ sender: UIPanGestureRecognizer) {
    guard let bannerView = sender.view else {
      return
    }

    let currentTouchPoint = sender.translation(in: self.view)

    if sender.state == .cancelled || sender.state == .ended {
      self.viewModel.inputs.showBannerView(shouldShow: false)

      return
    }

    let yPos = currentTouchPoint.y
    let heightLimit = bannerView.frame.height / 8

    if yPos == 0 {
      return
    } else if yPos < -heightLimit {
      // "rubber band" effect
      let absYPos = abs(yPos)
      let adjustedYPos =  heightLimit * (1 + log10(absYPos / heightLimit))

      self.backgroundViewBottomConstraint.constant = -adjustedYPos + self.bottomMarginConstraintConstant
    } else {
      self.backgroundViewBottomConstraint.constant = yPos + self.bottomMarginConstraintConstant
    }
  }

  @IBAction private func bannerViewTapped(_ sender: Any) {
    self.viewModel.inputs.showBannerView(shouldShow: false)
  }
}
