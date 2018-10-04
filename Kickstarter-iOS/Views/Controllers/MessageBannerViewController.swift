import Foundation
import Library
import Prelude

public enum MessageBannerType {
  case success
  case error
  case info

  var backgroundColor: UIColor {
    switch self {
    case .success:
      return UIColor.ksr_cobalt_500
    case .error:
      return UIColor.ksr_apricot_600
    case .info:
      return UIColor.ksr_cobalt_500
    }
  }

  var iconImage: UIImage? {
    switch self {
    case .success:
      return image(named: "icon--confirmation",
                   inBundle: Bundle.framework,
                   compatibleWithTraitCollection: nil)
    case .error:
      return image(named: "icon--alert",
                   inBundle: Bundle.framework,
                   compatibleWithTraitCollection: nil)
    default:
      return nil
    }
  }

  var textColor: UIColor {
    switch self {
    case .success, .info:
      return .white
    case .error:
      return UIColor.ksr_text_dark_grey_900
    }
  }

  var textAlignment: NSTextAlignment {
    switch self {
    case .info:
      return .center
    default:
      return .left
    }
  }

  var shouldShowIconImage: Bool {
    switch self {
    case .info:
      return false
    default:
      return true
    }
  }
}

final class MessageBannerViewController: UIViewController {
  @IBOutlet fileprivate weak var messageLabel: UILabel!
  @IBOutlet fileprivate weak var backgroundView: UIView!
  @IBOutlet fileprivate weak var backgroundViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var iconImageView: UIImageView!

  private var bottomMarginConstraintConstant: CGFloat = -Styles.grid(1)

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
    self.messageLabel.rac.textColor = self.viewModel.outputs.messageTextColor
    self.iconImageView.rac.hidden = self.viewModel.outputs.iconIsHidden
    self.backgroundView.rac.backgroundColor = self.viewModel.outputs.bannerBackgroundColor

    self.viewModel.outputs.messageBannerViewShouldShow
      .observeForUI()
      .observeValues { [weak self] shouldShow in
        self?.showViewAndAnimate(shouldShow)
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

  func setBannerType(type: MessageBannerType, message: String) {
    self.viewModel.inputs.setBannerType(type: type)
    self.viewModel.inputs.setBannerMessage(message: message)
  }

  func showBannerView() {
    self.viewModel.inputs.showBannerView(shouldShow: true)
  }

  private func showViewAndAnimate(_ shouldShow: Bool) {
    let duration = shouldShow ? 0.4 : 0.25

    if shouldShow {
      self.view.isHidden = false
    }

    UIView.animate(withDuration: duration, delay: 0.0,
                   options: UIView.AnimationOptions.curveEaseInOut,
                   animations: { [weak self] in
                    guard let `self` = self else { return }
      let frameHeight = self.view.frame.size.height
      self.backgroundViewBottomConstraint.constant = shouldShow
        ? self.bottomMarginConstraintConstant : frameHeight
      self.view.layoutIfNeeded()
    }, completion: { [weak self] _ in
      self?.view.isHidden = !shouldShow
    })
  }

  @IBAction func bannerViewPanned(_ sender: UIPanGestureRecognizer) {
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

  @IBAction func bannerViewTapped(_ sender: Any) {
    self.viewModel.inputs.showBannerView(shouldShow: false)
  }
}
