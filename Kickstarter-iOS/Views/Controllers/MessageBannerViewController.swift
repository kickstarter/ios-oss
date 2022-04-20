import Library
import Prelude
import UIKit

public protocol MessageBannerViewControllerPresenting {
  var messageBannerViewController: MessageBannerViewController? { get set }

  func configureMessageBannerViewController(on parentViewController: UIViewController)
    -> MessageBannerViewController?
}

public final class MessageBannerViewController: UIViewController, NibLoading {
  @IBOutlet fileprivate var backgroundView: UIView!
  @IBOutlet fileprivate var iconImageView: UIImageView!
  @IBOutlet fileprivate var messageLabel: UILabel!

  internal var bottomConstraint: NSLayoutConstraint?
  private let viewModel: MessageBannerViewModelType = MessageBannerViewModel()

  struct AnimationConstants {
    static let hideDuration: TimeInterval = 0.25
    static let showDuration: TimeInterval = 0.3
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.backgroundView
      |> \.isAccessibilityElement .~ true

    _ = self.messageLabel
      |> \.isAccessibilityElement .~ false
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .clear
      |> \.isHidden .~ true

    _ = self.backgroundView
      |> roundedStyle(cornerRadius: 4)

    _ = self.messageLabel
      |> UILabel.lens.font .~ .ksr_subhead()
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.iconImageView.rac.hidden = self.viewModel.outputs.iconIsHidden
    self.backgroundView.rac.backgroundColor = self.viewModel.outputs.bannerBackgroundColor
    self.backgroundView.rac.accessibilityLabel = self.viewModel.outputs.bannerMessageAccessibilityLabel
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
        guard let self = self else { return }
        _ = self.iconImageView
          |> UIImageView.lens.image .~ image
      }

    self.viewModel.outputs.messageTextAlignment
      .observeForUI()
      .observeValues { [weak self] textAlignment in
        guard let self = self else { return }

        _ = self.messageLabel
          |> UILabel.lens.textAlignment .~ textAlignment
      }
  }

  public func showBanner(with type: MessageBannerType, message: String) {
    self.viewModel.inputs.update(with: (type, message))
    self.viewModel.inputs.bannerViewWillShow(true)
  }

  private func showViewAndAnimate(_ isHidden: Bool) {
    let duration = isHidden ? AnimationConstants.hideDuration : AnimationConstants.showDuration

    let hiddenConstant = self.view.frame.height + (self.view.superview?.safeAreaInsets.bottom ?? 0)

    if !isHidden {
      self.view.superview?.bringSubviewToFront(self.view)

      self.view.isHidden = isHidden

      self.bottomConstraint?.constant = hiddenConstant

      // Force an early render to set the height
      self.view.superview?.layoutIfNeeded()
    }

    UIView.animate(
      withDuration: duration,
      delay: 0.0,
      options: .curveEaseInOut,
      animations: { [weak self] in
        guard let self = self else { return }

        if isHidden {
          // Tells VoiceOver to resign focus of the message banner.
          // This causes the reader to focus on the previously selected element.
          if AppEnvironment.current.isVoiceOverRunning() {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
          }
        }

        self.bottomConstraint?.constant = isHidden ? hiddenConstant : 0
        self.view.superview?.layoutIfNeeded()
      },
      completion: { [weak self] _ in
        self?.view.isHidden = isHidden

        self?.viewModel.inputs.bannerViewAnimationFinished(isHidden: isHidden)

        if !isHidden {
          // Tells VoiceOver to focus on the message banner.
          // This causes the reader to read the message and allows the user to dismiss the banner.
          if AppEnvironment.current.isVoiceOverRunning() {
            UIAccessibility.post(
              notification: UIAccessibility.Notification.layoutChanged,
              argument: self?.backgroundView
            )
          }
        }
      }
    )
  }

  @IBAction private func bannerViewPanned(_ sender: UIPanGestureRecognizer) {
    guard let view = sender.view else {
      return
    }

    let currentTouchPoint = sender.translation(in: self.view.superview)

    if sender.state == .cancelled || sender.state == .ended {
      self.viewModel.inputs.bannerViewWillShow(false)

      return
    }

    let yPos = currentTouchPoint.y
    let heightLimit = view.frame.height / 8

    if yPos == 0 {
      return
    } else if yPos < -heightLimit {
      // "rubber band" effect
      let absYPos = abs(yPos)
      let adjustedYPos = heightLimit * (1 + log10(absYPos / heightLimit))

      self.bottomConstraint?.constant = -adjustedYPos
    } else {
      self.bottomConstraint?.constant = yPos
    }
  }

  @IBAction private func bannerViewTapped(_: Any) {
    self.viewModel.inputs.bannerViewWillShow(false)
  }
}

extension MessageBannerViewControllerPresenting where Self: UIViewController {
  public func configureMessageBannerViewController(on parentViewController: UIViewController)
    -> MessageBannerViewController? {
    let nibName = Nib.MessageBannerViewController.rawValue
    let messageBannerViewController = MessageBannerViewController(
      nibName: nibName,
      bundle: .framework
    )

    guard let messageBannerView = messageBannerViewController.view else {
      return nil
    }

    parentViewController.addChild(messageBannerViewController)
    parentViewController.view.addSubview(messageBannerView)

    messageBannerViewController.didMove(toParent: parentViewController)

    messageBannerView.translatesAutoresizingMaskIntoConstraints = false

    let bottomViewBannerConstraint = messageBannerView.bottomAnchor
      .constraint(equalTo: parentViewController.view.layoutMarginsGuide.bottomAnchor)

    messageBannerViewController.bottomConstraint = bottomViewBannerConstraint

    parentViewController.view.addConstraints([
      bottomViewBannerConstraint,
      messageBannerView.leftAnchor.constraint(equalTo: parentViewController.view.leftAnchor),
      messageBannerView.rightAnchor.constraint(equalTo: parentViewController.view.rightAnchor)
    ])

    return messageBannerViewController
  }
}
