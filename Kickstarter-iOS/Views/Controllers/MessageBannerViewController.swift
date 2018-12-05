import Foundation
import Library
import Prelude

protocol MessageBannerViewControllerPresenting {
  var messageBannerViewController: MessageBannerViewController? { get set }

  func configureMessageBannerViewController(on parentViewController: UIViewController)
    -> MessageBannerViewController?
}

final class MessageBannerViewController: UIViewController, NibLoading {
  @IBOutlet fileprivate weak var backgroundView: UIView!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var iconImageView: UIImageView!
  @IBOutlet fileprivate weak var messageLabel: UILabel!

  internal var topViewConstraint: NSLayoutConstraint?

  private var bottomMarginConstraintConstant: CGFloat = -Styles.grid(1)
  private let viewModel: MessageBannerViewModelType = MessageBannerViewModel()
  private var isAnimating: Bool = false

  struct AnimationConstants {
    static let hideDuration: TimeInterval = 0.25
    static let showDuration: TimeInterval = 0.3
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .clear
      |> \.isHidden .~ true

    _ = self.containerView
      |> \.backgroundColor .~ .clear
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
    self.viewModel.inputs.bannerViewWillShow(true)
  }

  private func showViewAndAnimate(_ isHidden: Bool) {
    let duration = isHidden ? AnimationConstants.hideDuration : AnimationConstants.showDuration

    if !isHidden {
      self.view.isHidden = isHidden
    }

    self.isAnimating = true

    UIView.animate(withDuration: duration, delay: 0.0,
                   options: UIView.AnimationOptions.curveEaseInOut,
                   animations: { [weak self] in
                    guard let self = self else { return }
                    let frameHeight = self.view.frame.size.height
                    self.topViewConstraint?.constant = isHidden
                      ? 0 : -frameHeight
                    self.view.superview?.layoutIfNeeded()
    }, completion: { [weak self] _ in
      self?.isAnimating = false
      self?.view.isHidden = isHidden

      self?.viewModel.inputs.bannerViewAnimationFinished(isHidden: isHidden)
    })
  }

  @IBAction private func bannerViewPanned(_ sender: UIPanGestureRecognizer) {
    guard let view = sender.view, self.isAnimating == false else {
      return
    }

    let currentTouchPoint = sender.translation(in: self.view.superview)

    if sender.state == .cancelled || sender.state == .ended {
      self.viewModel.inputs.bannerViewWillShow(false)

      return
    }

    let yPos = currentTouchPoint.y
    let heightLimit = view.frame.height / 8
    let height = view.frame.height

    if yPos == 0 {
      return
    } else if yPos < -heightLimit {
      // "rubber band" effect
      let absYPos = abs(yPos)
      let adjustedYPos =  heightLimit * (1 + log10(absYPos / heightLimit))

      self.topViewConstraint?.constant = -(height + adjustedYPos)
    } else {
      self.topViewConstraint?.constant = -(height - yPos)
    }
  }

  @IBAction private func bannerViewTapped(_ sender: Any) {
    self.viewModel.inputs.bannerViewWillShow(false)
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
    messageBannerViewController.topViewConstraint = topViewBannerConstraint

    parentViewController.view.addConstraints([
      topViewBannerConstraint,
      messageBannerView.leftAnchor.constraint(equalTo: parentViewController.view.leftAnchor),
      messageBannerView.rightAnchor.constraint(equalTo: parentViewController.view.rightAnchor)
      ])

    return messageBannerViewController
  }
}
