import Library
import UIKit
import Prelude

public final class LandingViewController: UIViewController {
  // MARK: - Properties
  private lazy var backgroundImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var getStartedButton: UIButton = {
    UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var logoImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
    self.setupConstraints()

    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }

  override public func bindViewModel() {
    super.bindViewModel()
  }

  override public func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.backgroundImageView
      |> backgroundImageViewStyle

    _ = self.logoImageView
      |> logoImageViewStyle

    _ = self.getStartedButton
      |> getStartedButtonStyle

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.backgroundImageView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToCenterInParent()

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
      self.getStartedButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor,
                                                    constant: -Styles.grid(3)),
      self.getStartedButton.leftAnchor.constraint(equalTo: self.view.leftAnchor,
                                                  constant: Styles.grid(3)),
      self.getStartedButton.rightAnchor.constraint(equalTo: self.view.rightAnchor,
                                                   constant: -Styles.grid(3)),
      self.getStartedButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
    ])
  }
}

// MARK: - Styles

private let backgroundImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "landing-page-background")
    |> \.contentMode .~ .scaleAspectFill
}

private let getStartedButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in "Get started" }
}

private let logoImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)
    |> \.tintColor .~ UIColor.ksr_green_500
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
    |> \.layoutMargins .~ .init(leftRight: Styles.grid(3))
    |> \.alignment .~ .center
    |> \.distribution .~ .equalSpacing
    |> \.spacing .~ Styles.grid(2)
}
