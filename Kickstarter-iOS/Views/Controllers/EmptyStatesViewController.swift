import KsApi
import Library
import Prelude
import UIKit

internal protocol EmptyStatesViewControllerDelegate: class {
  func emptyStatesViewController(_ viewController: EmptyStatesViewController,
                                 goToDiscoveryWithParams params: DiscoveryParams?)
  func emptyStatesViewControllerGoToFriends()
}

internal final class EmptyStatesViewController: UIViewController {

  @IBOutlet fileprivate weak var backgroundGradientView: GradientView!
  @IBOutlet fileprivate weak var backgroundStripView: UIView!
  @IBOutlet fileprivate weak var mainButton: UIButton!
  @IBOutlet fileprivate weak var mainButtonBottomLayoutConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var headlineStackView: UIStackView!
  @IBOutlet fileprivate weak var stripViewTopLayoutConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var subtitleLabel: UILabel!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

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
      action: #selector(mainButtonTapped),
      for: .touchUpInside
    )
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

    override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.titleLabel.rac.textColor = self.viewModel.outputs.titleLabelColor

    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleLabelText
    self.subtitleLabel.rac.textColor = self.viewModel.outputs.subtitleLabelColor

    self.backgroundStripView.rac.alpha = self.viewModel.outputs.backgroundStripViewAlpha
    self.backgroundStripView.rac.backgroundColor = self.viewModel.outputs.backgroundStripViewColor

    self.mainButtonBottomLayoutConstraint.rac.constant = self.viewModel.outputs.bottomLayoutConstraintConstant

    self.mainButton.rac.title = self.viewModel.outputs.mainButtonText

    self.viewModel.outputs.mainButtonBackgroundColor
      .observeForUI()
      .observeValues { [weak element = mainButton] in
        _ = element
          ?|> UIButton.lens.backgroundColor(forState: .normal) .~ $0
    }

    self.viewModel.outputs.mainButtonTitleColor
      .observeForUI()
      .observeValues { [weak element = mainButton] in
        _ = element
          ?|> UIButton.lens.titleColor(forState: .normal) .~ $0
          ?|> UIButton.lens.titleColor(forState: .highlighted) .~ $0
    }

    self.viewModel.outputs.mainButtonBorderColor
      .observeForUI()
      .observeValues { [weak element = mainButton] in
        _ = element ?|> UIButton.lens.layer.borderColor .~ $0
    }

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
  // swiftlint:enable function_body_length

  override func bindStyles() {
    super.bindStyles()

    self.stripViewTopLayoutConstraint.constant = -Styles.grid(3)

    _ = self.view
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
      |> UILabel.lens.textAlignment .~ .left
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.subtitleLabel
      |> UILabel.lens.textAlignment .~ .left
      |> UILabel.lens.numberOfLines .~ 0

    _ = self.headlineStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(top: Styles.grid(1),
                                                 left: Styles.grid(4),
                                                 bottom: Styles.grid(7),
                                                 right: Styles.grid(4))

    _ = self.mainButton
      |> baseButtonStyle
      |> UIButton.lens.layer.borderWidth .~ 1.0
  }

  internal func setEmptyState(_ emptyState: EmptyState) {
    self.viewModel.inputs.setEmptyState(emptyState)
  }

  @objc func mainButtonTapped() {
    self.viewModel.inputs.mainButtonTapped()
  }
}
