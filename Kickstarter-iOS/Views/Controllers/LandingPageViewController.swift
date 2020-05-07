import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 54
  }

  enum ImageView {
    static let width: CGFloat = 226
  }

  enum Card {
    static let height: CGFloat = 122
  }
}

public final class LandingPageViewController: UIViewController {
  // MARK: - Properties

  private let backgroundImageView: UIImageView = { UIImageView(frame: .zero) }()
  private let cardsScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let cardsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let cardViewsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let ctaButton: UIButton = { UIButton(frame: .zero) }()
  private let descriptionLabel: UILabel = { UILabel(frame: .zero) }()
  private let labelsStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let logoImageView: UIImageView = { UIImageView(frame: .zero) }()
  private let pageControl: UIPageControl = { UIPageControl(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let scrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private let titleLabel: UILabel = { UILabel(frame: .zero) }()
  private let viewModel: LandingPageViewModelType = LandingPageViewModel()

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.setupConstraints()
    self.ctaButton.addTarget(
      self,
      action: #selector(LandingPageViewController.ctaButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewDidLoad()
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }

  // MARK: - View Model

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.landingPageCards
      .observeForUI()
      .observeValues { [weak self] cards in
        self?.configureCards(with: cards)
      }

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true)
      }

    self.viewModel.outputs.numberOfPages
      .observeForUI()
      .observeValues { [weak self] count in
        _ = self?.pageControl
          ?|> \.numberOfPages .~ count
      }
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> viewStyle

    _ = self.backgroundImageView
      |> backgroundImageViewStyle

    _ = self.cardsStackView
      |> cardsStackViewStyle

    _ = self.ctaButton
      |> ctaButtonStyle

    _ = self.descriptionLabel
      |> descriptionLabelStyle

    _ = self.labelsStackView
      |> labelsStackViewStyle

    _ = self.logoImageView
      |> logoImageViewStyle

    _ = self.pageControl
      |> pageControlStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.cardsScrollView
      |> cardsScrollViewStyle
      |> \.delegate .~ self

    _ = self.titleLabel
      |> titleLabelStyle
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (self.backgroundImageView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.logoImageView, self.titleLabel, self.descriptionLabel], self.labelsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.cardViewsStackView, self.cardsScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.cardsScrollView, self.pageControl], self.cardsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let spacer1 = UIView()

    _ = ([
      spacer1,
      self.labelsStackView,
      self.cardsStackView
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.ctaButton, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.ctaButton.heightAnchor.constraint(equalToConstant: Layout.Button.height),
      self.ctaButton.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
      self.ctaButton.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
      self.ctaButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
      self.cardsScrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Card.height),
      self.cardViewsStackView.heightAnchor.constraint(equalTo: self.cardsScrollView.heightAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor)
    ])
  }

  @objc private func ctaButtonTapped() {
    self.viewModel.inputs.ctaButtonTapped()
  }

  private func configureCards(with cards: [LandingPageCardType]) {
    let cardViews = self.cardViews(with: cards)

    _ = (cardViews, self.cardViewsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.setupViewsConstraints(cardViews)
  }

  private func cardViews(with cards: [LandingPageCardType]) -> [LandingPageStatsView] {
    return cards.map { card in
      let view = LandingPageStatsView(frame: .zero)

      view.configure(with: card)
      return view
    }
  }

  private func setupViewsConstraints(_ cardViews: [LandingPageStatsView]) {
    let layoutMarginsGuide = self.view.layoutMarginsGuide

    cardViews.forEach {
      NSLayoutConstraint.activate([
        $0.widthAnchor.constraint(equalTo: layoutMarginsGuide.widthAnchor)
      ])
    }
  }
}

// MARK: - Styles

private let backgroundImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.contentMode .~ .scaleAspectFill
    |> \.image .~ image(named: "landing-page-background")
}

private let cardsScrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.bounces .~ false
    |> \.isPagingEnabled .~ true
}

private let cardsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let ctaButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Get_started() }
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
}

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 0
    |> \.textColor .~ UIColor.ksr_text_dark_grey_500
    |> \.font .~ UIFont.ksr_callout()
    |> \.textAlignment .~ .center
    |> \.text %~ { _ in
      Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
    }
}

private let labelsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let logoImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ image(named: "kickstarter-logo")?.withRenderingMode(.alwaysTemplate)
    |> \.tintColor .~ .ksr_green_500
    |> \.contentMode .~ .scaleAspectFit
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.accessibilityLabel %~ { _ in Strings.general_accessibility_kickstarter() }
}

private let pageControlStyle: PageControlStyle = { pageControl in
  pageControl
    |> \.currentPage .~ 0
    |> \.currentPageIndicatorTintColor .~ .ksr_green_500
    |> \.pageIndicatorTintColor .~ .white
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(5)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ .init(top: Styles.grid(15), left: 0, bottom: Styles.grid(3), right: 0)
    |> \.distribution .~ .equalSpacing
}

private let scrollViewStyle: ScrollStyle = { scrollView in
  scrollView
    |> \.bounces .~ false
    |> \.isPagingEnabled .~ true
    |> \.showsHorizontalScrollIndicator .~ false
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.text %~ { _ in Strings.Bring_creative_projects_to_life() }
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.textAlignment .~ .center
    |> \.numberOfLines .~ 0
}

private let viewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ UIEdgeInsets.init(all: Styles.grid(3))
}

extension LandingPageViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageWidth = scrollView.bounds.width
    let pageFraction = scrollView.contentOffset.x / pageWidth

    _ = self.pageControl
      |> \.currentPage .~ Int(round(pageFraction))
  }
}
