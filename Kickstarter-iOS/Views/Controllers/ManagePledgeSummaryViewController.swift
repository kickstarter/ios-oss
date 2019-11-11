import Foundation
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  static let avatarWidth: CGFloat = 54.0
}

final class ManagePledgeSummaryViewController: UIViewController {
  // MARK: - Properties

  private lazy var backerInfoContainerStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var backerNumberLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var backingDateLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var circleAvatarImageView: CircleAvatarImageView = {
    CircleAvatarImageView.init(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pledgeAmountSummaryViewController: PledgeAmountSummaryViewController = {
    PledgeAmountSummaryViewController.instantiate()
  }()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalAmountLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var totalAmountStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var totalLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: ManagePledgeSummaryViewModelType = ManagePledgeSummaryViewModel()

  // MARK: - Lifecycle

  public func configureWith(_ project: Project) {
    self.viewModel.inputs.configureWith(project)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.circleAvatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.backerInfoContainerStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
      |> backerInfoContainerStackViewStyle

    _ = self.backerNameLabel
      |> backerNameLabelStyle

    _ = self.backerInfoStackView
      |> backerInfoStackViewStyle

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.totalAmountStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )

    _ = self.backerNumberLabel
      |> backerNumberLabelStyle

    _ = self.backingDateLabel
      |> backingDateLabelStyle

    _ = self.totalLabel
      |> totalLabelStyle

    _ = self.totalAmountLabel
      |> amountLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.configurePledgeAmountSummaryViewWithProject
      .observeForUI()
      .observeValues { [weak self] project in
        self?.pledgeAmountSummaryViewController.configureWith(project)
      }

    self.viewModel.outputs.backerImageURLAndPlaceholderImageName
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.circleAvatarImageView.af_cancelImageRequest()
        self?.circleAvatarImageView.image = nil
      })
      .observeValues { [weak self] url, placeholderImageName in
        self?.circleAvatarImageView
          .ksr_setImageWithURL(url, placeholderImage: UIImage(named: placeholderImageName))
      }

    self.backerNameLabel.rac.hidden = self.viewModel.outputs.backerNameLabelHidden
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerNameText
    self.backerNumberLabel.rac.text = self.viewModel.outputs.backerNumberText
    self.backingDateLabel.rac.text = self.viewModel.outputs.backingDateText
    self.circleAvatarImageView.rac.hidden = self.viewModel.outputs.circleAvatarViewHidden
    self.totalAmountLabel.rac.attributedText = self.viewModel.outputs.totalAmountText
  }

  // MARK: - Functions

  private func configureViews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.circleAvatarImageView, self.backerInfoStackView], self.backerInfoContainerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backerNameLabel, self.backerNumberLabel, self.backingDateLabel], self.backerInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.totalLabel, self.totalAmountLabel], self.totalAmountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.addChild(self.pledgeAmountSummaryViewController)

    _ = ([
      self.backerInfoContainerStackView,
      self.pledgeAmountSummaryViewController.view,
      self.totalAmountStackView
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeAmountSummaryViewController.didMove(toParent: self)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.circleAvatarImageView.widthAnchor.constraint(equalToConstant: Layout.avatarWidth),
      self.circleAvatarImageView.heightAnchor.constraint(equalTo: self.circleAvatarImageView.widthAnchor)
    ])
  }
}

// MARK: - Styles

private let amountLabelStyle: LabelStyle = { label in
  label
    |> checkoutLabelStyle
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.textAlignment .~ NSTextAlignment.right
    |> \.isAccessibilityElement .~ true
    |> \.minimumScaleFactor .~ 0.75
}

private let backerInfoContainerStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.spacing .~ Styles.grid(3)
}

private let backerNameLabelStyle: LabelStyle = { label in
  label
    |> checkoutLabelStyle
    |> \.font .~ .ksr_headline()
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
}

private let backerInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.gridHalf(1)
}

private let backerNumberLabelStyle: LabelStyle = { label in
  label
    |> checkoutLabelStyle
    |> \.textColor .~ UIColor.ksr_soft_black
    |> \.font .~ UIFont.ksr_footnote()
    |> \.adjustsFontForContentSizeCategory .~ true
}

private let backingDateLabelStyle: LabelStyle = { label in
  label
    |> checkoutLabelStyle
    |> \.font .~ UIFont.ksr_footnote()
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> checkoutStackViewStyle
    |> \.spacing .~ Styles.grid(3)
}

private let totalLabelStyle: LabelStyle = { label in
  label
    |> checkoutLabelStyle
    |> \.textColor .~ UIColor.black
    |> \.font .~ UIFont.ksr_subhead().bolded
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.text %~ { _ in Strings.Total_amount() }
}
