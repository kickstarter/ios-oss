import KsApi
import Library
import Prelude
import UIKit

internal protocol EmptyStatesViewControllerDelegate: class {
  func emptyStatesViewController(viewController: EmptyStatesViewController,
                                 goToDiscoveryWithParams params: DiscoveryParams?)
  func emptyStatesViewControllerGoToFriends()
}

internal final class EmptyStatesViewController: UIViewController {

  @IBOutlet private weak var backgroundGradientView: GradientView!
  @IBOutlet private weak var backgroundStripView: UIView!
  @IBOutlet private weak var mainButton: UIButton!
  @IBOutlet private weak var mainButtonBottomLayoutConstraint: NSLayoutConstraint!
  @IBOutlet private weak var headlineStackView: UIStackView!
  @IBOutlet private weak var stripViewTopLayoutConstraint: NSLayoutConstraint!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal weak var delegate: EmptyStatesViewControllerDelegate?

  private let viewModel: EmptyStatesViewModelType = EmptyStatesViewModel()

  internal static func configuredWith(emptyState emptyState: EmptyState) -> EmptyStatesViewController {
    let vc = Storyboard.EmptyStates.instantiate(EmptyStatesViewController)
    vc.viewModel.inputs.configureWith(emptyState: emptyState)
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.mainButton.addTarget(
      self,
      action: #selector(mainButtonTapped),
      forControlEvents: .TouchUpInside
    )
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  // swiftlint:disable function_body_length
  override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.text = self.viewModel.outputs.titleLabelText
    self.titleLabel.rac.textColor = self.viewModel.outputs.titleLabelColor

    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleLabelText
    self.subtitleLabel.rac.textColor = self.viewModel.outputs.subtitleLabelColor

    self.backgroundStripView.rac.alpha = self.viewModel.outputs.backgroundStripViewAlpha
    self.backgroundStripView.rac.backgroundColor = self.viewModel.outputs.backgroundStripViewColor

    self.mainButtonBottomLayoutConstraint.rac.constant = self.viewModel.outputs.bottomLayoutConstraintConstant

    self.viewModel.outputs.backgroundGradientColorId
      .observeForUI()
      .observeNext { [weak self] in
        let (endColor, startColor) = discoveryGradientColors(forCategoryId: $0)
        self?.backgroundGradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    }

    self.mainButton.rac.title = self.viewModel.outputs.mainButtonText

    self.viewModel.outputs.mainButtonBackgroundColor
      .observeForUI()
      .observeNext { [weak element = mainButton] in
        element
          ?|> UIButton.lens.backgroundColor(forState: .Normal) .~ $0
    }

    self.viewModel.outputs.mainButtonTitleColor
      .observeForUI()
      .observeNext { [weak element = mainButton] in
        element
          ?|> UIButton.lens.titleColor(forState: .Normal) .~ $0
          ?|> UIButton.lens.titleColor(forState: .Highlighted) .~ $0
    }

    self.viewModel.outputs.mainButtonBorderColor
      .observeForUI()
      .observeNext { [weak element = mainButton] in
        element ?|> UIButton.lens.layer.borderColor .~ $0
    }

    self.viewModel.outputs.notifyDelegateToGoToDiscovery
      .observeForControllerAction()
      .observeNext { [weak self] params in
        guard let _self = self else { return }
        _self.delegate?.emptyStatesViewController(_self, goToDiscoveryWithParams: params)
    }

    self.viewModel.outputs.notifyDelegateToGoToFriends
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.delegate?.emptyStatesViewControllerGoToFriends()
    }
  }
  // swiftlint:enable function_body_length

  override func bindStyles() {
    super.bindStyles()

    self.stripViewTopLayoutConstraint.constant = -Styles.grid(3)

    self.view
      |> UIView.lens.layoutMargins .~ self.traitCollection.isRegularRegular
        ? .init(top: 0, left: Styles.grid(4), bottom: Styles.grid(5), right: Styles.grid(4))
        : .init(top: 0, left: Styles.grid(2), bottom: Styles.grid(3), right: Styles.grid(2))

    self.titleLabel
      |> UILabel.lens.font .~ self.traitCollection.isRegularRegular
        ? UIFont.ksr_headline(size: 46).bolded
        : UIFont.ksr_headline(size: 36).bolded
      |> UILabel.lens.textAlignment .~ .Left
      |> UILabel.lens.numberOfLines .~ 0

    self.subtitleLabel
      |> UILabel.lens.font .~ self.traitCollection.isRegularRegular
        ? .ksr_callout(size: 22)
        : .ksr_callout()
      |> UILabel.lens.textAlignment .~ .Left
      |> UILabel.lens.numberOfLines .~ 0

    self.headlineStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(top: Styles.grid(1),
                                                 left: Styles.grid(4),
                                                 bottom: Styles.grid(7),
                                                 right: Styles.grid(4))

    self.mainButton
      |> baseButtonStyle
      |> UIButton.lens.layer.borderWidth .~ 1.0
  }

  @objc func mainButtonTapped() {
    self.viewModel.inputs.mainButtonTapped()
  }
}
