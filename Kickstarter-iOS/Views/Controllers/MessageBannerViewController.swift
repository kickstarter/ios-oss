import Foundation
import Library
import Prelude

protocol MessageBannerViewControllerPresenting {
  func configureMessageBannerViewController(on parentViewController: UIViewController)
    -> MessageBannerViewController?
}

final class MessageBannerViewController: UIViewController, NibLoading {
  @IBOutlet fileprivate weak var backgroundView: UIView!
  @IBOutlet fileprivate weak var iconImageView: UIImageView!
  @IBOutlet fileprivate weak var messageLabel: UILabel!

  internal var topViewConstraint: NSLayoutConstraint?
  internal var bottomViewConstraint: NSLayoutConstraint?
  private var bottomMarginConstraintConstant: CGFloat = -Styles.grid(1)
  private let viewModel: MessageBannerViewModelType = MessageBannerViewModel()

  struct AnimationConstants {
    static let hideDuration: TimeInterval = 0.25
    static let showDuration: TimeInterval = 0.3
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .clear
      |> \.isHidden .~ true
      |> \.layoutMargins .~ .init(all: Styles.grid(1))

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

    self.viewModel.outputs.iconTintColor
      .observeForUI()
      .observeValues { [weak self] color in
        _ = self?.iconImageView
          ?|> \.tintColor .~ color
    }

    self.viewModel.outputs.iconImageName
      .observeForUI()
      .map { image(named: $0, inBundle: Bundle.framework) }
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
    self.viewModel.inputs.update(with: (type, message))
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
                    guard let strongSelf = self else { return }
                    let frameHeight = strongSelf.view.frame.size.height
                    strongSelf.topViewConstraint?.constant = isHidden
                      ? 0 : -frameHeight
                    strongSelf.view.superview?.layoutIfNeeded()
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

      self.bottomViewConstraint?.constant = -adjustedYPos + self.bottomMarginConstraintConstant
    } else {
      self.bottomViewConstraint?.constant = yPos + self.bottomMarginConstraintConstant
    }
  }

  @IBAction private func bannerViewTapped(_ sender: Any) {
    self.viewModel.inputs.showBannerView(shouldShow: false)
  }
}

extension MessageBannerViewControllerPresenting where Self: UIViewController {
  func configureMessageBannerViewController(on parentViewController: UIViewController)
    -> MessageBannerViewController? {
    guard let messageBannerViewController = MessageBannerViewController
      .fromNib(nib: Nib.MessageBannerViewController),
          let messageBannerView = messageBannerViewController.view else {
      return nil
    }

    parentViewController.addChild(messageBannerViewController)
    parentViewController.view.addSubview(messageBannerView)

    messageBannerViewController.didMove(toParent: parentViewController)

    messageBannerView.translatesAutoresizingMaskIntoConstraints = false

    let topViewBannerConstraint = messageBannerView.topAnchor
      .constraint(equalTo: parentViewController.view.bottomAnchor)
    let bottomViewBannerConstraint = messageBannerView.bottomAnchor
      .constraint(greaterThanOrEqualTo: parentViewController.view.bottomAnchor)
    messageBannerViewController.topViewConstraint = topViewBannerConstraint
    messageBannerViewController.bottomViewConstraint = bottomViewBannerConstraint

    parentViewController.view.addConstraints([
      topViewBannerConstraint,
      bottomViewBannerConstraint,
      messageBannerView.leftAnchor.constraint(equalTo: parentViewController.view.leftAnchor),
      messageBannerView.rightAnchor.constraint(equalTo: parentViewController.view.rightAnchor)
      ])

    return messageBannerViewController
  }
}
