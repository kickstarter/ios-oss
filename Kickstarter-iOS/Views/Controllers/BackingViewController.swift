import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class BackingViewController: UIViewController {

  @IBOutlet fileprivate weak var actionsStackView: UIStackView!
  @IBOutlet fileprivate weak var backerAvatarImageView: UIImageView!
  @IBOutlet fileprivate weak var backerNameLabel: UILabel!
  @IBOutlet fileprivate weak var backerPledgeAmountAndDateLabel: UILabel!
  @IBOutlet fileprivate weak var backerRewardDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var backerSequenceLabel: UILabel!
  @IBOutlet fileprivate weak var backerShippingAmountLabel: UILabel!
  @IBOutlet fileprivate weak var contentView: UIView!
  @IBOutlet fileprivate weak var dividerView: UIView!
  @IBOutlet fileprivate weak var estimatedDeliveryDateLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryLabel: UILabel!
  @IBOutlet fileprivate weak var estimatedDeliveryStackView: UIStackView!
  @IBOutlet fileprivate weak var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var messageCreatorButton: UIButton!
  @IBOutlet fileprivate weak var pledgeCardView: UIView!
  @IBOutlet fileprivate weak var pledgeContainerView: UIView!
  @IBOutlet fileprivate weak var pledgeLabel: UILabel!
  @IBOutlet fileprivate weak var rewardCardView: UIView!
  @IBOutlet fileprivate weak var rewardContainerView: UIView!
  @IBOutlet fileprivate weak var rewardAmountLabel: UILabel!
  @IBOutlet fileprivate weak var rewardLabel: UILabel!
  @IBOutlet fileprivate weak var rewardTitleLabel: UILabel!
  @IBOutlet fileprivate weak var shippingLabel: UILabel!
  @IBOutlet fileprivate weak var shippingStackView: UIStackView!
  @IBOutlet fileprivate weak var statusDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var statusSubtitleLabel: UILabel!
  @IBOutlet fileprivate weak var statusTitleLabel: UILabel!
  @IBOutlet fileprivate weak var totalPledgedAmountLabel: UILabel!
  @IBOutlet fileprivate weak var totalPledgedLabel: UILabel!
  @IBOutlet fileprivate weak var viewMessagesButton: UIButton!

  private var navBarBorder = UIView()
  fileprivate let viewModel: BackingViewModelType = BackingViewModel()

  internal static func configuredWith(project: Project, backer: User?) -> BackingViewController {
    let vc = Storyboard.Backing.instantiate(BackingViewController.self)
    vc.viewModel.inputs.configureWith(project: project, backer: backer)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationController?.navigationBar
      ?|> UINavigationBar.lens.translucent .~ false
      ?|> UINavigationBar.lens.barTintColor .~ .white

    _ = self.messageCreatorButton
      |> UIButton.lens.targets .~ [(self, #selector(messageCreatorTapped), .touchUpInside)]

    _ = self.viewMessagesButton
      |> UIButton.lens.targets .~ [(self, #selector(viewMessagesTapped), .touchUpInside)]

    self.viewModel.inputs.viewDidLoad()

    if self.traitCollection.userInterfaceIdiom == .pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(closeButtonTapped))
    }
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()
    self.actionsStackView.rac.hidden = self.viewModel.outputs.hideActionsStackView
    self.actionsStackView.rac.axis = self.viewModel.outputs.rootStackViewAxis
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerName
    self.backerPledgeAmountAndDateLabel.rac.text = self.viewModel.outputs.backerPledgeAmountAndDate
    self.statusSubtitleLabel.rac.text = self.viewModel.outputs.backerPledgeStatus
    self.backerRewardDescriptionLabel.rac.text = self.viewModel.outputs.backerRewardDescription
    self.rewardTitleLabel.rac.text = self.viewModel.outputs.backerRewardTitle
    self.rewardTitleLabel.rac.hidden = self.viewModel.outputs.backerRewardTitleIsHidden
    self.backerSequenceLabel.rac.text = self.viewModel.outputs.backerSequence
    self.backerShippingAmountLabel.rac.text = self.viewModel.outputs.backerShippingAmount
    self.estimatedDeliveryDateLabel.rac.text = self.viewModel.outputs.estimatedDeliveryDateLabelText
    self.estimatedDeliveryStackView.rac.hidden = self.viewModel.outputs.estimatedDeliveryStackViewHidden
    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.loaderIsAnimating
    self.messageCreatorButton.rac.title = self.viewModel.outputs.messageButtonTitleText
    self.rewardAmountLabel.rac.text = self.viewModel.outputs.backerRewardAmount
    self.shippingStackView.rac.hidden = self.viewModel.outputs.shippingStackViewIsHidden
    self.statusDescriptionLabel.rac.text = self.viewModel.outputs.statusDescription
    self.totalPledgedAmountLabel.rac.text = self.viewModel.outputs.totalPledgeAmount

    self.viewModel.outputs.backerAvatarURL
      .observeForControllerAction()
      .on(event: { [weak backerAvatarImageView] _ in
        backerAvatarImageView?.af_cancelImageRequest()
        backerAvatarImageView?.image = nil
      })
      .skipNil()
      .observeValues { [weak backerAvatarImageView] url in
        backerAvatarImageView?.af_setImage(withURL: url)
    }

    self.viewModel.outputs.goToMessages
      .observeForControllerAction()
      .observeValues { [weak self] project, backing in
        self?.goToMessages(project: project, backing: backing)
    }

    self.viewModel.outputs.goToMessageCreator
      .observeForControllerAction()
      .observeValues { [weak self] messageSubject, context in
        self?.goToMessageCreator(messageSubject: messageSubject, context: context)
    }

    self.viewModel.outputs.opacityForContainers
      .observeForUI()
      .observeValues { [weak self] alpha in
        guard let _self = self else { return }
        UIView.animate(
          withDuration: (alpha == 0.0 ? 0.0 : 0.3),
          delay: 0.0,
          options: .curveEaseOut,
          animations: {
            _self.pledgeContainerView.alpha = alpha
            _self.rewardContainerView.alpha = alpha
          },
          completion: nil)
    }
  }

  // swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.project_view_button() }

    _ = self.contentView
      |> UIView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(4), left: Styles.grid(2),
                                                   bottom: Styles.grid(4), right: Styles.grid(2))

    _ = self.backerAvatarImageView
      |> UIImageView.lens.accessibilityElementsHidden .~ true

    _ = self.backerNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.backerSequenceLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.messageCreatorButton
      |> navyButtonStyle
      |> UIButton.lens.accessibilityHint %~ {  _ in Strings.Opens_message_composer() }

    _ = self.viewMessagesButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }

    _ = self.dividerView |> separatorStyle

    _ = [self.pledgeCardView, self.rewardCardView]
      ||> dropShadowStyle()

    _ = [self.pledgeContainerView, self.rewardContainerView]
      ||> UIView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.gridHalf(5), left: Styles.gridHalf(5),
                                                    bottom: Styles.gridHalf(5), right: Styles.grid(2))

    _ = self.totalPledgedLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.Total_pledged() }

    _ = self.totalPledgedAmountLabel
      |> UILabel.lens.font .~ .ksr_title2()
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.pledgeLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Pledge:") }

    _ = self.backerPledgeAmountAndDateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.shippingLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Shipping:") }

    _ = self.backerShippingAmountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.statusTitleLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in localizedString(key: "todo", defaultValue: "Status:") }

    _ = self.statusSubtitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.statusDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900

    _ = self.rewardLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 17)
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.Reward_selected() }

    _ = self.rewardAmountLabel
      |> UILabel.lens.font .~ UIFont.ksr_title2()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700

    _ = self.rewardTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_body()
      |> UILabel.lens.textColor .~ UIColor.ksr_text_navy_700

    _ = self.backerRewardDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500

    _ = self.estimatedDeliveryLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
      |> UILabel.lens.text %~ { _ in Strings.Estimated_delivery() }

    _ = self.estimatedDeliveryDateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.statusDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
  }

  @objc fileprivate func messageCreatorTapped(_ button: UIButton) {
    self.viewModel.inputs.messageCreatorTapped()
  }

  @objc fileprivate func viewMessagesTapped(_ button: UIButton) {
    self.viewModel.inputs.viewMessagesTapped()
  }

  fileprivate func goToMessages(project: Project, backing: Backing) {
    let vc = MessagesViewController.configuredWith(project: project, backing: backing)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToMessageCreator(messageSubject: MessageSubject,
                                      context: Koala.MessageDialogContext) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: context)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(nav, animated: true, completion: nil)
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension BackingViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_ dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
