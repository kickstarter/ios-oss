import Library
import Prelude
import UIKit

public final class LandingViewController: UIViewController {
  // MARK: - Properties

  private lazy var backgroundImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var getStartedButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var logoImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: LandingViewModelType = LandingViewModel()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.navigationController?.setNavigationBarHidden(true, animated: false)

    self.getStartedButton.addTarget(
      self,
      action: #selector(LandingViewController.getStartedButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewDidLoad()
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToCategorySelection
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        let categorySelectionVC = CategorySelectionViewController.instantiate()

        self?.navigationController?.pushViewController(categorySelectionVC, animated: true)
      }
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.backgroundImageView
      |> backgroundImageViewStyle
      |> \.image %~ { _ in image(
        named: "landing-background",
        inBundle: Bundle.framework,
        compatibleWithTraitCollection: self.view.traitCollection
      )
      }

    _ = self.logoImageView
      |> logoImageViewStyle

    _ = self.getStartedButton
      |> getStartedButtonStyle

    _ = self.rootStackView
      |> rootStackViewStyle
      |> \.layoutMargins %~ { _ in
        self.view.traitCollection.userInterfaceIdiom == .pad
          ? .init(leftRight: Styles.grid(10))
          : .init(leftRight: Styles.grid(3))
      }

    _ = self.scrollView
      |> scrollViewStyle
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updateScrollViewInsets()
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.backgroundImageView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.logoImageView, self.titleLabel, self.subtitleLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.getStartedButton, self.view)
      |> ksr_addSubviewToParent()

    [self.logoImageView, self.titleLabel, self.subtitleLabel].forEach { view in
      view.setContentHuggingPriority(.required, for: .vertical)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.getStartedButton.bottomAnchor.constraint(
        equalTo: self.view.layoutMarginsGuide.bottomAnchor,
        constant: -Styles.grid(3)
      ),
      self.getStartedButton.leftAnchor.constraint(
        equalTo: self.view.leftAnchor,
        constant: Styles.grid(3)
      ),
      self.getStartedButton.rightAnchor.constraint(
        equalTo: self.view.rightAnchor,
        constant: -Styles.grid(3)
      ),
      self.getStartedButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }

  private func updateScrollViewInsets() {
    self.rootStackView.layoutIfNeeded()

    let stackViewHeight = self.rootStackView.bounds.height
    let viewHeight = self.view.bounds.height
    let buttonHeight = self.getStartedButton.bounds.height + Styles.grid(3) // padding
    let inset = (viewHeight / 2) - stackViewHeight

    if stackViewHeight > viewHeight || inset < 0 {
      self.scrollView.contentInset.top = 0
    } else {
      self.scrollView.contentInset.top = inset
    }

    self.scrollView.contentInset.bottom = buttonHeight
  }

  // MARK: - Accessors

  @objc func getStartedButtonTapped() {
    self.viewModel.inputs.getStartedButtonTapped()
  }
}

// MARK: - Styles

private let backgroundImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFill
}

private let getStartedButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Get_started() }
}

private let logoImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)
    |> \.tintColor .~ UIColor.ksr_green_500
    |> \.accessibilityLabel %~ { _ in Strings.general_accessibility_kickstarter() }
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in Strings.Bring_creative_projects_to_life() }
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in
      Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
    }
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.alignment .~ .center
    |> \.distribution .~ .equalSpacing
    |> \.spacing .~ Styles.grid(2)
}

private let scrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.alwaysBounceVertical .~ true
}
