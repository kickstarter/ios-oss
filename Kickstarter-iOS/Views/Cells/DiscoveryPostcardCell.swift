import AlamofireImage
import KsApi
import Library
import Prelude
import UIKit

internal protocol DiscoveryPostcardCellDelegate: class {

  /// Called when the heart/save button is tapped
  func discoveryPostcardCellProjectSaveAlert()

  /// Called when logged out user taps heart/save button
  func discoveryPostcardCellGoToLoginTout()
}

internal final class DiscoveryPostcardCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: DiscoveryPostcardViewModelType = DiscoveryPostcardViewModel()
  internal weak var delegate: DiscoveryPostcardCellDelegate?

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var backgroundGradientView: GradientView!
  @IBOutlet fileprivate weak var backersSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var backersTitleLabel: UILabel!
  @IBOutlet fileprivate weak var deadlineSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var deadlineTitleLabel: UILabel!
  @IBOutlet fileprivate weak var fundingProgressBarView: UIView!
  @IBOutlet fileprivate weak var fundingProgressContainerView: UIView!
  @IBOutlet fileprivate weak var fundingSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var fundingTitleLabel: UILabel!
  @IBOutlet fileprivate weak var metadataBackgroundView: UIView!
  @IBOutlet fileprivate weak var metadataIconImageView: UIImageView!
  @IBOutlet fileprivate weak var metadataLabel: UILabel!
  @IBOutlet fileprivate weak var metadataStackView: UIStackView!
  @IBOutlet fileprivate weak var metadataView: UIView!
  @IBOutlet fileprivate weak var projectImageView: UIImageView!
  @IBOutlet fileprivate weak var projectInfoStackView: UIStackView!
  @IBOutlet fileprivate weak var projectNameAndBlurbLabel: UILabel!
  @IBOutlet fileprivate weak var projectStateSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectCategoriesStackView: UIStackView!
  @IBOutlet fileprivate weak var projectStateTitleLabel: UILabel!
  @IBOutlet fileprivate weak var projectStateStackView: UIStackView!
  @IBOutlet fileprivate weak var projectStatsStackView: UIStackView!
  @IBOutlet fileprivate weak var saveButton: UIButton!
  @IBOutlet fileprivate weak var socialAvatarImageView: UIImageView!
  @IBOutlet fileprivate weak var socialLabel: UILabel!
  @IBOutlet fileprivate weak var socialStackView: UIStackView!

  fileprivate weak var projectCategoryView: DiscoveryProjectCategoryView!
  fileprivate weak var projectIsStaffPickView: DiscoveryProjectCategoryView!

  private var projectSavedObserver: Any?
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  
  internal override func awakeFromNib() {
    if let categoryView = DiscoveryProjectCategoryView.fromNib(nib: Nib.DiscoveryProjectCategoryView) {
      projectCategoryView = categoryView

      projectCategoryView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
      projectCategoryView.setContentHuggingPriority(.required, for: .horizontal)

      projectCategoriesStackView.addArrangedSubview(projectCategoryView)
    }

    if let staffPickView = DiscoveryProjectCategoryView.fromNib(nib: Nib.DiscoveryProjectCategoryView) {
      projectIsStaffPickView = staffPickView

      projectIsStaffPickView.setContentCompressionResistancePriority(.required, for: .horizontal)
      projectCategoryView.setContentHuggingPriority(.defaultLow, for: .horizontal)

      projectCategoriesStackView.addArrangedSubview(projectIsStaffPickView)
    }
    
    self.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.sessionEndedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.projectSavedObserver = NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_projectSaved, object: nil, queue: nil) { [weak self]
        notification in
        self?.viewModel.inputs.projectFromNotification(project: notification.userInfo?["project"] as? Project)
      }
    
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
    self.backgroundGradientView.setGradient([
      (UIColor(white: 0, alpha: 0.5), 0),
      (UIColor(white: 0, alpha: 0), 1)
      ])

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

    _ = [self.backersTitleLabel, self.backersSubtitleLabel, self.deadlineTitleLabel,
         self.deadlineSubtitleLabel]
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

    _ = self.metadataBackgroundView
      |> cardStyle()

    _ = self.projectInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(4)

    _ = self.projectNameAndBlurbLabel
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.lineBreakMode .~ .byTruncatingTail

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

    _ = self.socialLabel
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_headline(size: 13.0)

    _ = self.socialStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins
        .~ .init(top: Styles.grid(2), left: Styles.grid(2), bottom: 0.0, right: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true
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
    self.saveButton.rac.selected = self.viewModel.outputs.saveButtonSelected
    self.saveButton.rac.enabled = self.viewModel.outputs.saveButtonEnabled
    self.projectIsStaffPickView.rac.hidden = viewModel.outputs.projectIsStaffPickLabelHidden
    
    projectIsStaffPickView.configureWith(name: Strings.Projects_We_Love(), imageNameString: "icon--small-k")
    
    viewModel.outputs.projectCategoryName
      .signal
      .observeForUI()
      .observeValues { (name) in
      self.projectCategoryView.configureWith(name: name, imageNameString: "icon--compass")
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
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.socialImageURL
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.socialAvatarImageView.af_cancelImageRequest()
        self?.socialAvatarImageView.image = nil
        })
      .skipNil()
      .observeValues { [weak self] url in
        self?.socialAvatarImageView.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.notifyDelegateShowSaveAlert
      .observeForUI()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.discoveryPostcardCellProjectSaveAlert()
    }

    self.viewModel.outputs.notifyDelegateShowLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        guard let _self = self else { return }
        _self.delegate?.discoveryPostcardCellGoToLoginTout()
    }
  }

  internal func configureWith(value: Project) {
    self.viewModel.inputs.configureWith(project: value)
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
    
    DispatchQueue.main.async { [weak self] in
      guard let strongSelf = self else { return }
      
      strongSelf.cardView.layer.shadowPath = UIBezierPath.init(rect: strongSelf.cardView.bounds).cgPath
      strongSelf.metadataBackgroundView.layer.shadowPath =
        UIBezierPath.init(rect: strongSelf.metadataBackgroundView.bounds).cgPath
    }
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }
}
