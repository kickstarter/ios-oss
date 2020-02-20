import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 54
  }

  enum ImageView {
    static let width: CGFloat = 226
  }
}

internal final class LandingPageViewController: UIViewController {
  // Properties

  private let backgroundImageView: UIImageView = { UIImageView(frame: .zero) }()
  private let ctaButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setTitle("Get started", for: .normal)

    return button
  }()
  private let descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let logoImageView: UIImageView = { UIImageView(frame: .zero) }()
  private let pageControl: UIPageControl = { UIPageControl(frame: .zero) }()
  private let scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private let statsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.setupConstraints()
    self.ctaButton.addTarget(self,
                             action: #selector(LandingPageViewController.ctaBUttonTapped),
                             for: .touchUpInside
    )
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.backgroundImageView
      |> backgroundImageViewStyle

    _ = self.ctaButton
      |> ctaButtonStyle

    _ = self.descriptionLabel
      |> descriptionLabelStyle

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.logoImageView
      |> logoImageViewStyle

    _ = self.titleLabel
      |> titleLabelStyle
  }

  // MARK - Configuration

  private func configureViews() {
    _ = (self.backgroundImageView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.logoImageView, self.titleLabel, self.descriptionLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.ctaButton, self.view)
       |> ksr_addSubviewToParent()

    _ = (self.labelsStackView, self.view)
      |> ksr_addSubviewToParent()
  }

  private func setupConstraints() {
    let viewMargins = self.view.layoutMarginsGuide

    NSLayoutConstraint.activate([
      self.labelsStackView.leftAnchor.constraint(equalTo: viewMargins.leftAnchor),
      self.labelsStackView.rightAnchor.constraint(equalTo: viewMargins.rightAnchor),
      self.labelsStackView.topAnchor.constraint(equalTo: viewMargins.topAnchor),
      self.ctaButton.leftAnchor.constraint(equalTo: viewMargins.leftAnchor),
      self.ctaButton.rightAnchor.constraint(equalTo: viewMargins.rightAnchor),
      self.ctaButton.bottomAnchor.constraint(equalTo: viewMargins.bottomAnchor),
      self.ctaButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.logoImageView.widthAnchor.constraint(equalToConstant: Layout.ImageView.width)
    ])
  }

  @objc private func ctaBUttonTapped() {

  }
}

// Styles

private let backgroundImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleToFill
    |> \.image .~ image(named: "landing-page-background")
}

private let ctaButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_callout()
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in  Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
    }
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(20), leftRight: 0)
}

private let logoImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)
    |> \.tintColor .~ .ksr_green_400
    |> \.contentMode .~ .scaleAspectFit
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.Bring_creative_projects_to_life() }
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.textAlignment .~ .center
}
