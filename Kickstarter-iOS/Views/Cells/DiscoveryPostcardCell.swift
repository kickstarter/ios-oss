import AlamofireImage
import KsApi
import Library
import Prelude
import UIKit

internal protocol DiscoveryPostcardCellDelegate: AnyObject {
  /// Called when the heart/save button is tapped
  func discoveryPostcardCellProjectSaveAlert()

  /// Called when logged out user taps heart/save button
  func discoveryPostcardCellGoToLoginTout()
}

internal final class DiscoveryPostcardCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DiscoveryPostcardViewModelType = DiscoveryPostcardViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()
  internal weak var delegate: DiscoveryPostcardCellDelegate?

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var backgroundGradientView: GradientView!
  @IBOutlet fileprivate var backersSubtitleLabel: UILabel!
  @IBOutlet fileprivate var backersTitleLabel: UILabel!
  @IBOutlet fileprivate var deadlineSubtitleLabel: UILabel!
  @IBOutlet fileprivate var deadlineTitleLabel: UILabel!
  @IBOutlet fileprivate var fundingProgressBarView: UIView!
  @IBOutlet fileprivate var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate var fundingSubtitleLabel: UILabel!
  @IBOutlet fileprivate var fundingTitleLabel: UILabel!
  @IBOutlet fileprivate var locationImageView: UIImageView!
  @IBOutlet fileprivate var locationLabel: UILabel!
  @IBOutlet fileprivate var locationStackView: UIStackView!
  @IBOutlet fileprivate var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate var metadataLabel: UILabel!
  @IBOutlet fileprivate var metadataStackView: UIStackView!
  @IBOutlet fileprivate var metadataView: UIView!
  @IBOutlet fileprivate var projectImageView: UIImageView!
  @IBOutlet fileprivate var projectNameAndBlurbLabel: UILabel!
  @IBOutlet fileprivate var projectStateSubtitleLabel: UILabel!
  @IBOutlet fileprivate var projectCategoriesStackView: UIStackView!
  @IBOutlet fileprivate var projectStateTitleLabel: UILabel!
  @IBOutlet fileprivate var projectStateStackView: UIStackView!
  @IBOutlet fileprivate var projectStatsStackView: UIStackView!
  @IBOutlet fileprivate var saveButton: UIButton!
  @IBOutlet fileprivate var socialAvatarImageView: UIImageView!
  @IBOutlet fileprivate var socialLabel: UILabel!
  @IBOutlet fileprivate var socialStackView: UIStackView!
  @IBOutlet fileprivate var projectStatsSocialLocationStackView: UIStackView!

  fileprivate weak var projectCategoryView: DiscoveryProjectCategoryView!
  fileprivate weak var projectIsStaffPickView: DiscoveryProjectCategoryView!

  private var projectSavedObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?

  internal override func awakeFromNib() {
    if let categoryView = DiscoveryProjectCategoryView.fromNib(nib: Nib.DiscoveryProjectCategoryView) {
      self.projectCategoryView = categoryView

      self.projectCategoryView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      self.projectCategoryView.setContentHuggingPriority(.required, for: .horizontal)

      self.projectCategoriesStackView.addArrangedSubview(self.projectCategoryView)
    }

    if let staffPickView = DiscoveryProjectCategoryView.fromNib(nib: Nib.DiscoveryProjectCategoryView) {
      self.projectIsStaffPickView = staffPickView

      self.projectIsStaffPickView.setContentCompressionResistancePriority(.required, for: .horizontal)
      self.projectIsStaffPickView.setContentHuggingPriority(.defaultLow, for: .horizontal)

      self.projectCategoriesStackView.addArrangedSubview(self.projectIsStaffPickView)
    }

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

    super.awakeFromNib()
  }

  deinit {
    self.projectSavedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionEndedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.backgroundGradientView.startPoint = .zero
    self.backgroundGradientView.endPoint = CGPoint(x: 0, y: 1)
    let gradient: [(UIColor?, Float)] = [
      (UIColor.init(white: 0.0, alpha: 0.5), 0),
      (UIColor.init(white: 0.0, alpha: 0.0), 1)
    ]
    self.backgroundGradientView.setGradient(gradient)

    _ = self
      |> baseTableViewCellStyle()
      // Future: the top should adjust to grid(4) when there is metadata present.
      |> DiscoveryPostcardCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(30))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))
      }
      |> DiscoveryPostcardCell.lens.accessibilityHint %~ { _ in
        Strings.dashboard_tout_accessibility_hint_opens_project()
      }

    _ = [self.backersTitleLabel, self.deadlineTitleLabel]
      ||> postcardStatsTitleStyle

    _ = [self.backersSubtitleLabel, self.deadlineSubtitleLabel, self.fundingSubtitleLabel]
      ||> postcardStatsSubtitleStyle

    _ = [
      self.backersTitleLabel, self.backersSubtitleLabel, self.deadlineTitleLabel,
      self.deadlineSubtitleLabel
    ]
      ||> UILabel.lens.textColor .~ .ksr_text_dark_grey_500

    _ = self.backersSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.discovery_baseball_card_stats_backers() }

    _ = self.fundingTitleLabel
      |> postcardStatsTitleStyle
      |> UILabel.lens.textColor .~ .ksr_green_700

    _ = self.fundingSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.discovery_baseball_card_stats_funded() }
      |> UILabel.lens.textColor .~ .ksr_green_700

    _ = self.cardView
      |> cardStyle()

    _ = self.fundingProgressContainerView
      |> UIView.lens.backgroundColor .~ .ksr_navy_400

    _ = self.fundingProgressBarView
      |> UIView.lens.backgroundColor .~ .ksr_green_700

    _ = self.metadataIconImageView
      |> UIImageView.lens.tintColor .~ .ksr_dark_grey_500

    _ = self.metadataLabel
      |> postcardMetadataLabelStyle

    _ = self.metadataStackView
      |> postcardMetadataStackViewStyle

    _ = self.metadataView
      |> cardStyle()
      |> \.layoutMargins .~ .init(all: Styles.grid(1))

    _ = self.projectImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.projectStatsSocialLocationStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: Styles.grid(3))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.projectNameAndBlurbLabel
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail
      |> UILabel.lens.backgroundColor .~ .white

    _ = self.projectStateSubtitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.font .~ .ksr_body(size: 13)
      |> UILabel.lens.numberOfLines .~ 1
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    _ = self.projectStateTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)

    _ = self.projectStateStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.projectStatsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    _ = self.saveButton
      |> discoverySaveButtonStyle

    _ = self.socialAvatarImageView
      |> UIImageView.lens.layer.shouldRasterize .~ true

    _ = self.socialAvatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.socialLabel
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_headline(size: 13.0)

    _ = self.socialStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.locationStackView
      |> locationStackViewStyle

    _ = self.locationLabel
      |> locationLabelStyle

    _ = self.locationImageView
      |> locationImageViewStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.backersTitleLabel.rac.text = self.viewModel.outputs.backersTitleLabelText
    self.backersSubtitleLabel.rac.text = self.viewModel.outputs.backersSubtitleLabelText
    self.deadlineSubtitleLabel.rac.text = self.viewModel.outputs.deadlineSubtitleLabelText
    self.deadlineTitleLabel.rac.text = self.viewModel.outputs.deadlineTitleLabelText
    self.fundingProgressContainerView.rac.hidden = self.viewModel.outputs.fundingProgressContainerViewHidden
    self.fundingProgressBarView.rac.hidden = self.viewModel.outputs.fundingProgressBarViewHidden
    self.fundingTitleLabel.rac.text = self.viewModel.outputs.percentFundedTitleLabelText
    self.locationLabel.rac.text = self.viewModel.outputs.locationLabelText
    self.locationStackView.rac.hidden = self.viewModel.outputs.locationStackViewHidden
    self.metadataLabel.rac.text = self.viewModel.outputs.metadataLabelText
    self.metadataLabel.rac.textColor = self.viewModel.outputs.metadataTextColor
    self.metadataIconImageView.rac.tintColor = self.viewModel.outputs.metadataIconImageViewTintColor
    self.metadataView.rac.hidden = self.viewModel.outputs.metadataViewHidden
    self.projectNameAndBlurbLabel.rac.attributedText = self.viewModel.outputs.projectNameAndBlurbLabelText
    self.projectStateSubtitleLabel.rac.text = self.viewModel.outputs.projectStateSubtitleLabelText
    self.projectStateTitleLabel.rac.textColor = self.viewModel.outputs.projectStateTitleLabelColor
    self.projectStateTitleLabel.rac.text = self.viewModel.outputs.projectStateTitleLabelText
    self.projectStateStackView.rac.hidden = self.viewModel.outputs.projectStateStackViewHidden
    self.projectStatsStackView.rac.hidden = self.viewModel.outputs.projectStatsStackViewHidden
    self.socialLabel.rac.text = self.viewModel.outputs.socialLabelText
    self.socialStackView.rac.hidden = self.viewModel.outputs.socialStackViewHidden
    self.saveButton.rac.selected = self.watchProjectViewModel.outputs.saveButtonSelected
    self.projectIsStaffPickView.rac.hidden = self.viewModel.outputs.projectIsStaffPickLabelHidden
    self.projectCategoryView.rac.hidden = self.viewModel.outputs.projectCategoryViewHidden
    self.projectCategoriesStackView.rac.hidden = self.viewModel.outputs.projectCategoryStackViewHidden

    self.projectIsStaffPickView.configureWith(
      name: Strings.Projects_We_Love(), imageNameString: "icon--small-k"
    )

    self.watchProjectViewModel.outputs.generateImpactFeedback
      .observeForUI()
      .observeValues { _ in generateImpactFeedback() }

    self.watchProjectViewModel.outputs.generateNotificationSuccessFeedback
      .observeForUI()
      .observeValues { generateNotificationSuccessFeedback() }

    self.watchProjectViewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.viewModel.outputs.projectCategoryName
      .signal
      .observeForUI()
      .observeValues { [weak self] name in
        self?.projectCategoryView.configureWith(name: name, imageNameString: "icon--compass")
      }

    self.viewModel.outputs.metadataIcon
      .observeForUI()
      .observeValues { [weak self] icon in
        self?.metadataIconImageView.image = icon
      }

    self.viewModel.outputs.progressPercentage
      .observeForUI()
      .observeValues { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.fundingProgressBarView.layer.anchorPoint = CGPoint(x: CGFloat(anchorX), y: 0.5)
        self?.fundingProgressBarView.transform = CGAffineTransform(scaleX: CGFloat(progress), y: 1.0)
      }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }

    self.watchProjectViewModel.outputs.showNotificationDialog
      .observeForUI()
      .observeValues { n in
        NotificationCenter.default.post(n)
      }

    self.viewModel.outputs.socialImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.socialAvatarImageView.af.cancelImageRequest()
        self?.socialAvatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.socialAvatarImageView.ksr_setRoundedImageWith(url)
      }

    self.watchProjectViewModel.outputs.showProjectSavedAlert
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.discoveryPostcardCellProjectSaveAlert()
      }

    self.watchProjectViewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.discoveryPostcardCellGoToLoginTout()
      }
  }

  internal func configureWith(value: DiscoveryProjectCellRowValue) {
    self.viewModel.inputs.configure(with: value)

    self.watchProjectViewModel.inputs.configure(with: (
      value.project,
      Koala.LocationContext.discovery,
      value.params
    ))
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }

      strongSelf.cardView.layer.shadowPath = UIBezierPath.init(rect: strongSelf.cardView.bounds).cgPath
      strongSelf.metadataView.layer.shadowPath =
        UIBezierPath.init(rect: strongSelf.metadataView.bounds).cgPath
    }
  }

  @objc fileprivate func saveButtonPressed(_: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTouched()
  }

  @objc fileprivate func saveButtonTapped(_ button: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: button.isSelected)
  }
}

// MARK: - Styles

private let locationStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.alignment .~ .center
    |> \.distribution .~ .fill
    |> \.spacing .~ Styles.grid(1)
}

private let locationLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_footnote()
    |> \.textColor .~ .ksr_text_dark_grey_500
    |> \.lineBreakMode .~ .byTruncatingTail
    |> \.numberOfLines .~ 1
}

private let locationImageViewStyle: ImageViewStyle = { imageView in
  imageView
    |> UIImageView.lens.image .~ Library.image(named: "location-icon")
    |> \.tintColor .~ .ksr_dark_grey_400
    |> \.contentMode .~ .scaleAspectFit
}
