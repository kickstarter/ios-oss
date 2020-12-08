import KsApi
import Library
import Prelude
import UIKit

internal protocol EmptyStatesViewControllerDelegate: AnyObject {
  func emptyStatesViewController(
    _ viewController: EmptyStatesViewController,
    goToDiscoveryWithParams params: DiscoveryParams?
  )
  func emptyStatesViewControllerGoToFriends()
}

internal final class EmptyStatesViewController: UIViewController {
  @IBOutlet fileprivate var backgroundStripView: UIView!
  @IBOutlet fileprivate var mainButton: UIButton!
  @IBOutlet fileprivate var mainButtonBottomLayoutConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var headlineStackView: UIStackView!
  @IBOutlet fileprivate var stripViewTopLayoutConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var subtitleLabel: UILabel!
  @IBOutlet fileprivate var titleLabel: UILabel!

  internal weak var delegate: EmptyStatesViewControllerDelegate?

  fileprivate let viewModel: EmptyStatesViewModelType = EmptyStatesViewModel()

  internal static func configuredWith(emptyState: EmptyState?) -> EmptyStatesViewController {
    let vc = Storyboard.EmptyStates.instantiate(EmptyStatesViewController.self)
    vc.viewModel.inputs.configureWith(emptyState: emptyState)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.mainButton.addTarget(
      self,
      action: #selector(self.mainButtonTapped),
      for: .touchUpInside
    )
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.bottomLayoutConstraintConstant.observeValues { [weak self] constant in
      self?.mainButtonBottomLayoutConstraint
        .constant = constant + (self?.view.layoutMargins.bottom ?? 0)
    }

    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleLabelText
    self.mainButton.rac.title = self.viewModel.outputs.mainButtonText

    self.viewModel.outputs.notifyDelegateToGoToDiscovery
      .observeForControllerAction()
      .observeValues { [weak self] params in
        guard let _self = self else { return }
        _self.delegate?.emptyStatesViewController(_self, goToDiscoveryWithParams: params)
      }

    self.viewModel.outputs.notifyDelegateToGoToFriends
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.delegate?.emptyStatesViewControllerGoToFriends()
      }
  }

  override func bindStyles() {
    super.bindStyles()

    self.stripViewTopLayoutConstraint.constant = -Styles.grid(3)

    _ = self.view
      |> UIView.lens.backgroundColor .~ .ksr_white
      |> UIView.lens.layoutMargins .~ (
        self.traitCollection.isRegularRegular
          ? .init(top: 0, left: Styles.grid(4), bottom: Styles.grid(5), right: Styles.grid(4))
          : .init(top: 0, left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))
      )

    if self.traitCollection.isRegularRegular {
      _ = self.titleLabel |> UILabel.lens.font .~ UIFont.ksr_headline(size: 46).bolded
      _ = self.subtitleLabel |> UILabel.lens.font .~ .ksr_callout(size: 22)
    } else if self.traitCollection.isVerticallyCompact {
      _ = self.titleLabel |> UILabel.lens.font .~ UIFont.ksr_headline(size: 26).bolded
      _ = self.subtitleLabel |> UILabel.lens.font .~ .ksr_callout(size: 13)
    } else {
      _ = self.titleLabel |> UILabel.lens.font .~ UIFont.ksr_headline(size: 36).bolded
      _ = self.subtitleLabel |> UILabel.lens.font .~ .ksr_callout()
    }

    _ = self.titleLabel
      |> UILabel.lens.backgroundColor .~ .ksr_white
      |> UILabel.lens.textAlignment .~ .left
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.textColor .~ .ksr_support_700

    _ = self.subtitleLabel
      |> UILabel.lens.backgroundColor .~ .ksr_white
      |> UILabel.lens.textAlignment .~ .left
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.textColor .~ .ksr_support_700

    _ = self.headlineStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(
        top: Styles.grid(1),
        left: Styles.grid(4),
        bottom: Styles.grid(7),
        right: Styles.grid(4)
      )

    _ = self.mainButton
      |> greenButtonStyle

    _ = self.backgroundStripView
      |> UIView.lens.backgroundColor .~ .ksr_white
  }

  internal func setEmptyState(_ emptyState: EmptyState) {
    self.viewModel.inputs.setEmptyState(emptyState)
  }

  @objc func mainButtonTapped() {
    self.viewModel.inputs.mainButtonTapped()
  }
}
