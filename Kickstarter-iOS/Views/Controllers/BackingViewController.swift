import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

internal final class BackingViewController: UIViewController {
  @IBOutlet fileprivate var actionsStackView: UIStackView!
  @IBOutlet fileprivate var backerAvatarImageView: UIImageView!
  @IBOutlet fileprivate var backerNameLabel: UILabel!
  @IBOutlet fileprivate var backerPledgeAmountLabel: UILabel!
  @IBOutlet fileprivate var backerRewardDescriptionLabel: UILabel!
  @IBOutlet fileprivate var backerSequenceLabel: UILabel!
  @IBOutlet fileprivate var backerShippingAmountLabel: UILabel!
  @IBOutlet fileprivate var contentView: UIView!
  @IBOutlet fileprivate var dividerView: UIView!
  @IBOutlet fileprivate var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate var markAsReceivedStackView: UIStackView!
  @IBOutlet fileprivate var markAsReceivedLabelStackView: UIStackView!
  @IBOutlet fileprivate var messageCreatorButton: UIButton!
  @IBOutlet fileprivate var pledgeContainerView: UIView!
  @IBOutlet fileprivate var pledgeLabel: UILabel!
  @IBOutlet fileprivate var pledgeSectionTitleLabel: UILabel!
  @IBOutlet fileprivate var rewardContainerView: UIView!
  @IBOutlet fileprivate var rewardDeliveredLabel: UILabel!
  @IBOutlet fileprivate var rewardReceivedSwitch: UISwitch!
  @IBOutlet fileprivate var rewardSectionTitleLabel: UILabel!
  @IBOutlet fileprivate var rewardTitleWithAmountLabel: UILabel!
  @IBOutlet fileprivate var shippingLabel: UILabel!
  @IBOutlet fileprivate var shippingPlusLabel: UILabel!
  @IBOutlet fileprivate var shippingStackView: UIStackView!
  @IBOutlet fileprivate var statusDescriptionLabel: UILabel!
  @IBOutlet fileprivate var totalPledgedAmountLabel: UILabel!
  @IBOutlet fileprivate var totalPledgedLabel: UILabel!
  @IBOutlet fileprivate var useThisToKeepTrackLabel: UILabel!
  @IBOutlet fileprivate var viewMessagesButton: UIButton!

  fileprivate let viewModel: BackingViewModelType = BackingViewModel()

  internal static func configuredWith(project: Project, backer: User?) -> BackingViewController {
    let vc = Storyboard.Backing.instantiate(BackingViewController.self)
    vc.viewModel.inputs.configureWith(project: project, backer: backer)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.messageCreatorButton
      |> UIButton.lens.targets .~ [(self, #selector(messageCreatorTapped), .touchUpInside)]

    _ = self.viewMessagesButton
      |> UIButton.lens.targets .~ [(self, #selector(viewMessagesTapped), .touchUpInside)]

    self.viewModel.inputs.viewDidLoad()

    if self.traitCollection.userInterfaceIdiom == .pad {
      self.navigationItem.leftBarButtonItem = .close(self, selector: #selector(self.closeButtonTapped))
    }
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()
    self.actionsStackView.rac.axis = self.viewModel.outputs.rootStackViewAxis
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerName
    self.backerPledgeAmountLabel.rac.text = self.viewModel.outputs.pledgeAmount
    self.backerRewardDescriptionLabel.rac.text = self.viewModel.outputs.rewardDescription
    self.pledgeSectionTitleLabel.rac.attributedText = self.viewModel.outputs.pledgeSectionTitle
    self.rewardSectionTitleLabel.rac.attributedText = self.viewModel.outputs.rewardSectionTitle
    self.backerSequenceLabel.rac.text = self.viewModel.outputs.backerSequence
    self.backerShippingAmountLabel.rac.text = self.viewModel.outputs.shippingAmount
    self.backerShippingAmountLabel.rac.hidden = self.viewModel.outputs.rewardSectionAndShippingIsHidden
    self.rewardContainerView.rac.hidden = self.viewModel.outputs.rewardSectionAndShippingIsHidden
    self.rewardTitleWithAmountLabel.rac.text = self.viewModel.outputs.rewardTitleWithAmount
    self.loadingIndicatorView.rac.animating = self.viewModel.outputs.loaderIsAnimating
    self.statusDescriptionLabel.rac.attributedText = self.viewModel.outputs.statusDescription
    self.totalPledgedAmountLabel.rac.text = self.viewModel.outputs.totalPledgeAmount
    self.shippingStackView.rac.hidden = self.viewModel.outputs.rewardSectionAndShippingIsHidden
    self.messageCreatorButton.rac.title = self.viewModel.outputs.messageButtonTitleText
    self.markAsReceivedStackView.rac.hidden = self.viewModel.outputs.markAsReceivedSectionIsHidden
    self.rewardReceivedSwitch.rac.on = self.viewModel.outputs.rewardMarkedReceived
    self.backerAvatarImageView.rac.imageUrl = self.viewModel.outputs.backerAvatarURL

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
          withDuration: alpha == 0.0 ? 0.0 : 0.3,
          delay: 0.0,
          options: .curveEaseOut,
          animations: {
            _self.pledgeContainerView.alpha = alpha
            _self.rewardContainerView.alpha = alpha
          },
          completion: nil
        )
      }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.project_view_button() }

    _ = self.backerAvatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.contentView
      |> UIView.lens.layoutMargins .~ UIEdgeInsets(
        top: Styles.grid(5), left: Styles.grid(2),
        bottom: Styles.grid(4), right: Styles.grid(2)
      )

    _ = self.backerAvatarImageView
      |> UIImageView.lens.accessibilityElementsHidden .~ true

    _ = self.backerNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.backerSequenceLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.messageCreatorButton
      |> blackButtonStyle
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Opens_message_composer() }

    _ = self.viewMessagesButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }

    _ = self.dividerView
      |> UIView.lens.backgroundColor .~ .ksr_grey_500

    _ = [self.pledgeContainerView, self.rewardContainerView]
      ||> cardStyle(cornerRadius: 2.0)
      ||> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      ||> UIView.lens.layoutMargins .~ UIEdgeInsets(
        top: Styles.gridHalf(5), left: Styles.gridHalf(5),
        bottom: Styles.gridHalf(5), right: Styles.grid(2)
      )

    _ = self.totalPledgedLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 15)
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.text %~ { _ in Strings.Total_pledged() }

    _ = self.totalPledgedAmountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 15)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.pledgeLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.text %~ { _ in Strings.Pledge() }

    _ = self.backerPledgeAmountLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.shippingLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.text %~ { _ in Strings.Shipping() }

    _ = self.shippingPlusLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.text .~ "+"

    _ = self.backerShippingAmountLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.loadingIndicatorView
      |> baseActivityIndicatorStyle

    _ = self.useThisToKeepTrackLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.rewardDeliveredLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in Strings.Reward_delivered() }

    _ = self.useThisToKeepTrackLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.text %~ { _ in Strings.Use_this_to_keep_track_of_which_rewards_youve_received() }

    _ = self.rewardSectionTitleLabel
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.markAsReceivedStackView
      |> UIStackView.lens.alignment .~ .top
      |> UIStackView.lens.distribution .~ .fill

    _ = self.markAsReceivedLabelStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.rewardTitleWithAmountLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_soft_black

    _ = self.backerRewardDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400

    _ = self.statusDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
  }

  @objc fileprivate func messageCreatorTapped(_: UIButton) {
    self.viewModel.inputs.messageCreatorTapped()
  }

  @objc fileprivate func viewMessagesTapped(_: UIButton) {
    self.viewModel.inputs.viewMessagesTapped()
  }

  fileprivate func goToMessages(project: Project, backing: Backing) {
    guard let nav = self.navigationController else { return }

    if nav.children.contains(where: { $0 is MessagesViewController }) {
      nav.popViewController(animated: true)
      return
    }

    let vc = MessagesViewController.configuredWith(project: project, backing: backing)
    nav.pushViewController(vc, animated: true)
  }

  fileprivate func goToMessageCreator(
    messageSubject: MessageSubject,
    context: Koala.MessageDialogContext
  ) {
    let vc = MessageDialogViewController.configuredWith(messageSubject: messageSubject, context: context)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    vc.delegate = self
    self.present(nav, animated: true, completion: nil)
  }

  @IBAction fileprivate func rewardReceivedTapped(_ receivedSwitch: UISwitch) {
    self.viewModel.inputs.rewardReceivedTapped(on: receivedSwitch.isOn)
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension BackingViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(_ dialog: MessageDialogViewController) {
    dialog.dismiss(animated: true, completion: nil)
  }

  internal func messageDialog(_: MessageDialogViewController, postedMessage _: Message) {}
}
