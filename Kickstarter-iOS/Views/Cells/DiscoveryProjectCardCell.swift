import Foundation
import KsApi
import Library
import Prelude
import UIKit

private enum FacepileAvatarSize {
  static let height: CGFloat = 26.0
  static let width: CGFloat = 26.0
}

final class DiscoveryProjectCardCell: UITableViewCell, ValueCell {
  private enum IconImageSize {
    static let height: CGFloat = 13.0
    static let width: CGFloat = 13.0
  }

  internal weak var delegate: DiscoveryPostcardCellDelegate?

  // MARK: - Properties

  private lazy var backersCountLabel = { UILabel(frame: .zero) }()
  private lazy var backersCountIconImageView = { UIImageView(frame: .zero) }()
  private lazy var backersCountStackView = { UIStackView(frame: .zero) }()
  private lazy var cardContainerView = { UIView(frame: .zero) }()
  private lazy var dataSource = { DiscoveryProjectTagsCollectionViewDataSource() }()
  private lazy var facepileAvatarContainerView = { UIView(frame: .zero) }()
  private var facepileAvatarImageViews: [UIImageView] = [UIImageView]()
  private lazy var facepileDescriptionLabel = { UILabel(frame: .zero) }()
  private lazy var facepileStackView = { UIStackView(frame: .zero) }()
  private lazy var goalMetIconImageView = { UIImageView(frame: .zero) }()
  private lazy var goalPercentFundedStackView = { UIStackView(frame: .zero) }()
  private lazy var percentFundedLabel = { UILabel(frame: .zero) }()
  private lazy var pillLayout: PillLayout = {
    PillLayout(
      minimumInteritemSpacing: Styles.grid(1),
      minimumLineSpacing: Styles.grid(1),
      sectionInset: .init(top: Styles.grid(1))
    )
  }()

  private lazy var projectDetailsStackView = { UIStackView(frame: .zero) }()
  private lazy var projectBlurbLabel = { UILabel(frame: .zero) }()
  private lazy var projectImageView = { UIImageView(frame: .zero) }()
  // Stack view container for "percent funded" and "backer count" info
  private lazy var projectInfoStackView = { UIStackView(frame: .zero) }()
  private lazy var projectNameLabel = { UILabel(frame: .zero) }()
  private lazy var projectStatusContainerView = { UIView(frame: .zero) }()
  private lazy var projectStatusIconImageView = { UIImageView(frame: .zero) }()
  private lazy var projectStatusLabel = { UILabel(frame: .zero) }()
  private lazy var projectStatusStackView = { UIStackView(frame: .zero) }()
  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var saveButton = { UIButton(type: .custom) }()

  private lazy var tagsCollectionView: UICollectionView = {
    UICollectionView(
      frame: .zero,
      collectionViewLayout: self.pillLayout
    )
      |> \.contentInsetAdjustmentBehavior .~ UIScrollView.ContentInsetAdjustmentBehavior.never
      |> \.dataSource .~ self.dataSource
      |> \.allowsSelection .~ false
  }()

  private var tagsCollectionViewHeightConstraint: NSLayoutConstraint?
  private lazy var youreABackerLabel = { UILabel(frame: .zero) }()
  private lazy var youreABackerView = { UIView(frame: .zero) }()

  private let viewModel: DiscoveryProjectCardViewModelType = DiscoveryProjectCardViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  // MARK: - Notification Observers

  private var projectSavedObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureSubviews()
    self.setupConstraints()
    self.addShadowLayers()
    self.configureWatchProjectObservers()

    self.tagsCollectionView.registerCellClass(DiscoveryProjectTagPillCell.self)

    self.dataSource.collectionView = self.tagsCollectionView

    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    [
      self.projectSavedObserver,
      self.sessionEndedObserver,
      self.sessionStartedObserver
    ]
    .forEach { $0.doIfSome(NotificationCenter.default.removeObserver) }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    self.updateCollectionViewConstraints()
    self.updateShadowLayerPaths()
  }

  func configureWith(value: DiscoveryProjectCellRowValue) {
    self.viewModel.inputs.configure(with: value)

    self.watchProjectViewModel.inputs.configure(with: (
      value.project,
      Koala.LocationContext.discovery,
      value.params
    ))

    self.setNeedsLayout()
    self.layoutIfNeeded()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.selectionStyle .~ .none

    _ = self.contentView
      |> contentViewStyle
      |> \.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular ?
          .init(
            top: Styles.grid(1),
            left: Styles.grid(30),
            bottom: Styles.grid(1),
            right: Styles.grid(30)
          ) : .init(
            top: Styles.grid(1),
            left: Styles.grid(2),
            bottom: Styles.grid(1),
            right: Styles.grid(2)
          )
      }

    _ = self.rootStackView
      |> verticalStackViewStyle
      |> \.spacing .~ 0

    _ = self.saveButton
      |> saveButtonStyle

    _ = self.cardContainerView
      |> cardContainerViewStyle

    _ = self.projectImageView
      |> projectImageViewStyle

    _ = self.projectDetailsStackView
      |> projectDetailsStackViewStyle

    _ = self.projectStatusContainerView
      |> projectStatusContainerViewStyle

    _ = self.projectStatusStackView
      |> adaptableStackViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)
      |> \.spacing .~ Styles.grid(1)
      |> \.alignment %~ { _ in
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? .leading : .center
      }

    _ = self.projectStatusIconImageView
      |> projectStatusIconImageStyle

    _ = self.projectNameLabel
      |> projectNameLabelStyle

    _ = self.projectBlurbLabel
      |> projectBlurbLabelStyle

    _ = self.percentFundedLabel
      |> percentFundedLabelStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .horizontal) .~ .defaultLow

    _ = self.backersCountLabel
      |> backersCountLabelStyle

    _ = self.projectStatusLabel
      |> projectStatusLabelStyle

    _ = self.facepileDescriptionLabel
      |> facepileDescriptionLabelStyle

    _ = self.backersCountStackView
      |> infoStackViewStyle

    _ = self.goalPercentFundedStackView
      |> infoStackViewStyle

    _ = self.goalMetIconImageView
      |> goalMetIconImageViewStyle

    _ = self.backersCountIconImageView
      |> backersCountIconImageViewStyle

    _ = self.projectInfoStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> projectInfoStackViewStyle

    _ = self.facepileStackView
      |> facepileStackViewStyle

    _ = self.tagsCollectionView
      |> collectionViewStyle

    _ = self.youreABackerView
      |> youreABackerViewStyle

    _ = self.youreABackerLabel
      |> youreABackerLabelStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.goalMetIconImageView.rac.hidden = self.viewModel.outputs.goalMetIconHidden
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.tagsCollectionView.rac.hidden = self.viewModel.outputs.tagsCollectionViewHidden
    self.facepileDescriptionLabel.rac.text = self.viewModel.outputs.facepileViewData.map(second)
    self.facepileStackView.rac.hidden = self.viewModel.outputs.facepileViewHidden
    self.youreABackerView.rac.hidden = self.viewModel.outputs.youreABackerViewHidden
    self.saveButton.rac.selected = self.watchProjectViewModel.outputs.saveButtonSelected

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.facepileViewData.map(first)
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.clearFacepileImageViews()
      })
      .observeValues { [weak self] avatars in
        self?.configureFacepileImageViews(with: avatars)
      }

    self.viewModel.outputs.percentFundedLabelData
      .observeForUI()
      .observeValues { [weak self] boldedString, fullString in
        guard let self = self else { return }

        let attributedString = self.attributedString(bolding: boldedString, in: fullString)

        _ = self.percentFundedLabel
          |> \.attributedText .~ attributedString
      }

    self.viewModel.outputs.backerCountLabelData
      .observeForUI()
      .observeValues { [weak self] boldedString, fullString in
        guard let self = self else { return }

        let attributedString = self.attributedString(bolding: boldedString, in: fullString)

        _ = self.backersCountLabel
          |> \.attributedText .~ attributedString
      }

    self.viewModel.outputs.projectStatusLabelData
      .observeForUI()
      .observeValues { [weak self] boldedString, fullString in
        guard let self = self else { return }

        let attributedString = self.attributedString(bolding: boldedString, in: fullString)

        _ = self.projectStatusLabel
          |> \.attributedText .~ attributedString
      }

    self.viewModel.outputs.projectStatusIconImageName
      .observeForUI()
      .observeValues { [weak self] imageName in
        _ = self?.projectStatusIconImageView
          ?|> \.image .~ Library.image(named: imageName)
      }

    self.viewModel.outputs.loadProjectTags
      .observeForUI()
      .observeValues { [weak self] tags in
        self?.dataSource.load(with: tags)

        self?.tagsCollectionView.reloadData()

        self?.updateCollectionViewConstraints()
      }

    // Watch Project View Model

    self.watchProjectViewModel.outputs.showProjectSavedAlert
      .observeForUI()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.discoveryPostcardCellProjectSaveAlert()
      }

    self.watchProjectViewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let self = self else { return }
        self.delegate?.discoveryPostcardCellGoToLoginTout()
      }

    self.watchProjectViewModel.outputs.showNotificationDialog
      .observeForUI()
      .observeValues { n in
        NotificationCenter.default.post(n)
      }

    self.watchProjectViewModel.outputs.generateImpactFeedback
      .observeForUI()
      .observeValues { _ in generateImpactFeedback() }

    self.watchProjectViewModel.outputs.generateNotificationSuccessFeedback
      .observeForUI()
      .observeValues { generateNotificationSuccessFeedback() }

    self.watchProjectViewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }
  }

  // MARK: - Functions

  private func configureSubviews() {
    _ = (self.cardContainerView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.cardContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent(priority: UILayoutPriority(rawValue: 999))

    _ = ([self.projectImageView, self.projectDetailsStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.saveButton, self.cardContainerView)
      |> ksr_addSubviewToParent()

    _ = (self.projectStatusContainerView, self.cardContainerView)
      |> ksr_addSubviewToParent()

    _ = (self.youreABackerView, self.cardContainerView)
      |> ksr_addSubviewToParent()

    _ = (self.youreABackerLabel, self.youreABackerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.projectStatusStackView, self.projectStatusContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.projectStatusIconImageView, self.projectStatusLabel], self.projectStatusStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.facepileAvatarContainerView, self.facepileDescriptionLabel], self.facepileStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([
      self.projectNameLabel,
      self.projectBlurbLabel,
      self.projectInfoStackView,
      self.facepileStackView,
      self.tagsCollectionView
    ], self.projectDetailsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.goalMetIconImageView, self.percentFundedLabel], self.goalPercentFundedStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backersCountIconImageView, self.backersCountLabel], self.backersCountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    let spacer = UIView(frame: .zero)
      |> UIView.lens.contentHuggingPriority(for: .horizontal) .~ UILayoutPriority(rawValue: 249)

    _ = (
      [self.goalPercentFundedStackView, self.backersCountStackView, spacer],
      self.projectInfoStackView
    )
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = [
      self.rootStackView,
      self.projectImageView,
      self.projectStatusContainerView,
      self.youreABackerView,
      self.goalMetIconImageView,
      self.backersCountIconImageView,
      self.saveButton,
      self.tagsCollectionView
    ]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false

    let aspectRatio = CGFloat(9.0 / 16.0)

    self.tagsCollectionViewHeightConstraint = self.tagsCollectionView.heightAnchor
      .constraint(greaterThanOrEqualToConstant: 0)
      |> \.isActive .~ true

    NSLayoutConstraint.activate([
      self.projectImageView.widthAnchor.constraint(equalTo: self.cardContainerView.widthAnchor),
      self.projectImageView.heightAnchor.constraint(
        equalTo: self.projectImageView.widthAnchor,
        multiplier: aspectRatio
      ),
      self.youreABackerView.centerYAnchor.constraint(
        equalTo: self.projectImageView.bottomAnchor,
        constant: -Styles.grid(1)
      ),
      self.youreABackerView.leftAnchor.constraint(
        equalTo: self.cardContainerView.leftAnchor,
        constant: Styles.grid(3)
      ),
      self.saveButton.topAnchor.constraint(
        equalTo: self.cardContainerView.topAnchor,
        constant: Styles.grid(2)
      ),
      self.saveButton.rightAnchor.constraint(
        equalTo: self.cardContainerView.rightAnchor,
        constant: -Styles.grid(2)
      ),
      self.projectStatusContainerView.topAnchor.constraint(
        equalTo: self.cardContainerView.topAnchor,
        constant: Styles.grid(2)
      ),
      self.projectStatusContainerView.leftAnchor.constraint(
        equalTo: self.cardContainerView.leftAnchor,
        constant: Styles.grid(2)
      ),
      self.projectStatusContainerView.rightAnchor.constraint(
        lessThanOrEqualTo: self.saveButton.leftAnchor,
        constant: -Styles.grid(2)
      ),
      self.projectStatusContainerView.bottomAnchor
        .constraint(
          lessThanOrEqualTo: self.projectDetailsStackView.topAnchor,
          constant: -Styles.grid(2)
        )
    ])
  }

  private func attributedString(bolding boldedString: String, in fullString: String) -> NSAttributedString {
    let attributedString: NSMutableAttributedString = NSMutableAttributedString.init(string: fullString)
    let regularFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_footnote().bolded]
    let boldFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_subhead().bolded]
    let fullRange = (fullString as NSString).localizedStandardRange(of: fullString)
    let boldedRange: NSRange = (fullString as NSString).localizedStandardRange(of: boldedString)

    attributedString.addAttributes(regularFontAttribute, range: fullRange)
    attributedString.addAttributes(boldFontAttribute, range: boldedRange)

    return attributedString
  }

  private func configureWatchProjectObservers() {
    self.saveButton.addTarget(self, action: #selector(self.saveButtonTapped(_:)), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(self.saveButtonPressed(_:)), for: .touchDown)

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionStarted()
      }

    self.sessionEndedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionEnded()
      }

    self.projectSavedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_projectSaved, object: nil, queue: nil) { [weak self]
        notification in
        self?.watchProjectViewModel.inputs.projectFromNotification(
          project: notification.userInfo?["project"] as? Project
        )
      }

    self.watchProjectViewModel.inputs.awakeFromNib()
  }

  private func updateCollectionViewConstraints() {
    self.tagsCollectionView.layoutIfNeeded()

    self.tagsCollectionViewHeightConstraint?.constant = self.tagsCollectionView.contentSize.height

    self.layoutIfNeeded()
  }

  private func addShadowLayers() {
    let projectStatusShadowLayer = CAShapeLayer()
      |> \.fillColor .~ UIColor.white.withAlphaComponent(0.95).cgColor
      |> \.shadowColor .~ UIColor.black.cgColor
      |> \.shadowOpacity .~ 0.15
      |> \.shadowRadius .~ 4
      |> \.shadowOffset .~ CGSize(width: 0, height: 1)

    projectStatusShadowLayer.shadowPath = projectStatusShadowLayer.path

    self.projectStatusContainerView.layer.insertSublayer(projectStatusShadowLayer, at: 0)

    let saveButtonShadowLayer = CAShapeLayer()
      |> \.fillColor .~ UIColor.white.withAlphaComponent(0.95).cgColor
      |> \.shadowColor .~ UIColor.black.cgColor
      |> \.shadowOpacity .~ 0.15
      |> \.shadowRadius .~ 4
      |> \.shadowOffset .~ CGSize(width: 0, height: 1)

    saveButtonShadowLayer.shadowPath = saveButtonShadowLayer.path

    self.saveButton.layer.insertSublayer(saveButtonShadowLayer, at: 0)
  }

  private func updateShadowLayerPaths() {
    if let projectStatusShadowLayer = self.projectStatusContainerView.layer.sublayers?[0] as? CAShapeLayer {
      projectStatusShadowLayer.path = UIBezierPath(
        roundedRect: self.projectStatusContainerView.bounds,
        cornerRadius: Styles.grid(1)
      ).cgPath
    }

    if let saveButtonShadowLayer = self.saveButton.layer.sublayers?
      .first(where: { $0 is CAShapeLayer }) as? CAShapeLayer {
      let cornerRadius = self.saveButton.bounds.width / 2

      saveButtonShadowLayer.path = UIBezierPath(
        roundedRect: self.saveButton.bounds,
        cornerRadius: cornerRadius
      ).cgPath

      if let imageView = self.saveButton.imageView {
        self.saveButton.bringSubviewToFront(imageView)
      }
    }
  }

  private func configureFacepileImageViews(with avatars: [URL]) {
    let endIndex = avatars.endIndex

    self.facepileAvatarImageViews = avatars.enumerated().map { index, imageURL -> UIImageView in
      let overlap = CGFloat(index) * Styles.grid(1)
      let xOffset = index == 0 ? 0 : (CGFloat(index) * FacepileAvatarSize.width - overlap)

      let imageView = UIImageView(frame: .zero)
        |> avatarImageViewStyle

      self.facepileAvatarContainerView.addSubview(imageView)
      self.facepileAvatarContainerView.sendSubviewToBack(imageView)

      imageView.ksr_setRoundedImageWith(imageURL)

      NSLayoutConstraint.activate([
        imageView.widthAnchor.constraint(equalToConstant: FacepileAvatarSize.width),
        imageView.heightAnchor.constraint(equalToConstant: FacepileAvatarSize.height),
        imageView.leftAnchor.constraint(
          equalTo: self.facepileAvatarContainerView.leftAnchor,
          constant: xOffset
        ),
        imageView.topAnchor.constraint(equalTo: self.facepileAvatarContainerView.topAnchor),
        imageView.bottomAnchor.constraint(equalTo: self.facepileAvatarContainerView.bottomAnchor)
      ])

      // Last avatar
      if index == endIndex - 1 {
        _ = imageView.rightAnchor.constraint(equalTo: self.facepileAvatarContainerView.rightAnchor)
          |> \.isActive .~ true
      }

      return imageView
    }

    self.facepileAvatarContainerView.layoutIfNeeded()
  }

  private func clearFacepileImageViews() {
    self.facepileAvatarImageViews.forEach { imageView in
      imageView.af.cancelImageRequest()
      imageView.image = nil

      imageView.removeFromSuperview()
    }

    self.facepileAvatarImageViews = []
  }

  // MARK: - Accessors

  @objc fileprivate func saveButtonPressed(_: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTouched()
  }

  @objc fileprivate func saveButtonTapped(_ button: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: button.isSelected)
  }
}

// MARK: - Styles

private let avatarImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.layer.borderColor .~ UIColor.white.cgColor
    |> \.backgroundColor .~ UIColor.ksr_grey_400
    |> \.layer.borderWidth .~ 2
    |> \.clipsToBounds .~ true
    |> ignoresInvertColorsImageViewStyle
    |> roundedStyle(cornerRadius: FacepileAvatarSize.width / 2)
}

private let collectionViewStyle: ViewStyle = { view in
  view
    |> \.backgroundColor .~ .white
}

private let contentViewStyle: ViewStyle = { view in
  view
    |> \.preservesSuperviewLayoutMargins .~ false
    |> \.backgroundColor .~ .ksr_grey_200
}

private let cardContainerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> \.backgroundColor .~ .white
}

private let projectStatusContainerViewStyle: ViewStyle = { view in
  view
    |> \.layoutMargins .~ .init(topBottom: Styles.gridHalf(2), leftRight: Styles.gridHalf(3))
}

private let goalMetIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ Library.image(named: "icon--star")
    |> \.tintColor .~ .ksr_green_500
    |> \.contentMode .~ .center
}

private let projectImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.clipsToBounds .~ true
    |> \.backgroundColor .~ .ksr_grey_400
    |> \.contentMode .~ .scaleAspectFill
    |> ignoresInvertColorsImageViewStyle
}

private let projectNameLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 2
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_headline().bolded
    |> \.textColor .~ .ksr_soft_black
    |> \.backgroundColor .~ .white
}

private let projectBlurbLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 2
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.font .~ UIFont.ksr_subhead()
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.backgroundColor .~ .white
}

private let projectStatusLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.textColor .~ .ksr_soft_black
    |> \.backgroundColor .~ .clear
}

private let facepileDescriptionLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 2
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.textColor .~ .ksr_soft_black
    |> \.font .~ UIFont.ksr_footnote().bolded
}

private let projectStatusIconImageStyle: ImageViewStyle = { imageView in
  imageView
    |> \.tintColor .~ .ksr_text_dark_grey_500
    |> \.contentMode .~ .center
}

private let infoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .horizontal
    |> \.spacing .~ Styles.grid(1)
    |> \.alignment .~ .fill
    |> \.distribution .~ .fill
}

private let percentFundedLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.textColor .~ .ksr_green_500
    |> \.backgroundColor .~ .white
}

private let backersCountIconImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> \.image .~ Library.image(named: "icon--humans")
    |> \.tintColor .~ .ksr_dark_grey_500
    |> \.contentMode .~ .center
}

private let backersCountLabelStyle: LabelStyle = { label in
  label
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.textColor .~ .ksr_soft_black
    |> \.backgroundColor .~ .white
}

private let projectInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(2)
}

private let facepileStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .center
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(1)
}

private let projectDetailsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
    |> \.alignment .~ .fill
    |> \.layoutMargins .~ .init(all: Styles.grid(3))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.insetsLayoutMarginsFromSafeArea .~ false
}

private let saveButtonStyle: ButtonStyle = { button in
  button
    |> discoverySaveButtonStyle
}

private let youreABackerViewStyle: ViewStyle = { view in
  view
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.backgroundColor .~ UIColor.ksr_cobalt_500
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(1), leftRight: Styles.gridHalf(3))
}

private let youreABackerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.textColor .~ UIColor.white
    |> \.numberOfLines .~ 1
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.text %~ { _ in Strings.Youre_a_backer_no_punctuation() }
}
