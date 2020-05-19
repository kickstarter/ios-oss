import Foundation
import KsApi
import Library
import Prelude
import UIKit

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
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    self.tagsCollectionViewHeightConstraint?.constant = 0
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
            top: Styles.grid(2),
            left: Styles.grid(30),
            bottom: 0,
            right: Styles.grid(30)
          ) : .init(
            top: Styles.grid(2),
            left: Styles.grid(2),
            bottom: 0,
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
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.projectBlurbLabel
      |> projectBlurbLabelStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.percentFundedLabel
      |> percentFundedLabelStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.backersCountLabel
      |> backersCountLabelStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.projectStatusLabel
      |> projectStatusLabelStyle

    _ = self.backersCountStackView
      |> infoStackViewStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.goalPercentFundedStackView
      |> infoStackViewStyle
      |> UIView.lens.contentCompressionResistancePriority(for: .vertical) .~ .required

    _ = self.goalMetIconImageView
      |> goalMetIconImageViewStyle

    _ = self.backersCountIconImageView
      |> backersCountIconImageViewStyle

    _ = self.projectInfoStackView
      |> adaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> projectInfoStackViewStyle

    _ = self.tagsCollectionView
      |> collectionViewStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.goalMetIconImageView.rac.hidden = self.viewModel.outputs.goalMetIconHidden
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectNameLabelText
    self.projectBlurbLabel.rac.text = self.viewModel.outputs.projectBlurbLabelText
    self.tagsCollectionView.rac.hidden = self.viewModel.outputs.tagsCollectionViewHidden

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
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

    _ = (self.projectStatusStackView, self.projectStatusContainerView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.projectStatusIconImageView, self.projectStatusLabel], self.projectStatusStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([
      self.projectNameLabel,
      self.projectBlurbLabel,
      self.projectInfoStackView,
      self.tagsCollectionView
    ], self.projectDetailsStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.goalMetIconImageView, self.percentFundedLabel], self.goalPercentFundedStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backersCountIconImageView, self.backersCountLabel], self.backersCountStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.goalPercentFundedStackView, self.backersCountStackView], self.projectInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    _ = [
      self.rootStackView,
      self.projectImageView,
      self.projectStatusContainerView,
      self.goalMetIconImageView,
      self.backersCountIconImageView,
      self.saveButton,
      self.tagsCollectionView
    ]
      ||> \.translatesAutoresizingMaskIntoConstraints .~ false

    let aspectRatio = CGFloat(9.0 / 16.0)

    let imageViewHeightConstraint = self.projectImageView.heightAnchor.constraint(
      equalTo:
      self.projectImageView.widthAnchor,
      multiplier: aspectRatio
    )
      |> \.priority .~ .defaultHigh

    self.tagsCollectionViewHeightConstraint = self.tagsCollectionView.heightAnchor
      .constraint(greaterThanOrEqualToConstant: 0)
      |> \.isActive .~ true

    let goalMetIconWidth = self.goalMetIconImageView.widthAnchor
      .constraint(equalToConstant: IconImageSize.width)
      |> \.priority .~ .defaultHigh
    let goalMetIconHeight = self.goalMetIconImageView.heightAnchor
      .constraint(equalToConstant: IconImageSize.height)
      |> \.priority .~ .defaultHigh
    let backersIconWidth = self.backersCountIconImageView.widthAnchor
      .constraint(equalToConstant: IconImageSize.width)
      |> \.priority .~ .defaultHigh
    let backersIconHeight = self.backersCountIconImageView.heightAnchor
      .constraint(equalToConstant: IconImageSize.height)
      |> \.priority .~ .defaultHigh

    NSLayoutConstraint.activate([
      self.projectImageView.widthAnchor.constraint(equalTo: self.cardContainerView.widthAnchor),
      imageViewHeightConstraint,
      self.saveButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.saveButton.widthAnchor.constraint(equalToConstant: Styles.minTouchSize.width),
      self.saveButton.topAnchor.constraint(equalTo: self.cardContainerView.topAnchor),
      self.saveButton.rightAnchor.constraint(equalTo: self.cardContainerView.rightAnchor),
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
        ),
      goalMetIconWidth,
      goalMetIconHeight,
      backersIconWidth,
      backersIconHeight,
      self.tagsCollectionView.widthAnchor
        .constraint(equalTo: self.projectDetailsStackView.layoutMarginsGuide.widthAnchor)
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
    |> roundedStyle(cornerRadius: Styles.grid(1))
    |> \.backgroundColor .~ UIColor.white.withAlphaComponent(0.8)
    |> \.layoutMargins .~ .init(all: Styles.gridHalf(3))
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
    |> \.distribution .~ .equalSpacing
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

private let projectDetailsStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
    |> \.spacing .~ Styles.grid(2)
    |> \.alignment .~ .leading
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
    |> \.isLayoutMarginsRelativeArrangement .~ true
}

private let saveButtonStyle: ButtonStyle = { button in
  button
    |> discoverySaveButtonStyle
}
