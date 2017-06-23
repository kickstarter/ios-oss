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
  @IBOutlet fileprivate weak var backerPledgeAmountLabel: UILabel!
  @IBOutlet fileprivate weak var backerRewardDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var backerSequenceLabel: UILabel!
  @IBOutlet fileprivate weak var backerShippingAmountLabel: UILabel!
  @IBOutlet fileprivate weak var contentView: UIView!
  @IBOutlet fileprivate weak var dividerView: UIView!
  @IBOutlet fileprivate weak var loadingIndicatorView: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var messageCreatorButton: UIButton!
  @IBOutlet fileprivate weak var pledgeContainerView: UIView!
  @IBOutlet fileprivate weak var pledgeLabel: UILabel!
  @IBOutlet fileprivate weak var pledgeSectionTitleLabel: UILabel!
  @IBOutlet fileprivate weak var rewardContainerView: UIView!
  @IBOutlet fileprivate weak var rewardSectionTitleLabel: UILabel!
  @IBOutlet fileprivate weak var rewardTitleWithAmountLabel: UILabel!
  @IBOutlet fileprivate weak var shippingLabel: UILabel!
  @IBOutlet fileprivate weak var shippingPlusLabel: UILabel!
  @IBOutlet fileprivate weak var shippingStackView: UIStackView!
  @IBOutlet fileprivate weak var statusDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var totalPledgedAmountLabel: UILabel!
  @IBOutlet fileprivate weak var totalPledgedLabel: UILabel!
  @IBOutlet fileprivate weak var viewMessagesButton: UIButton!

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
      |> UIViewController.lens.view.backgroundColor .~ .ksr_grey_300
      |> UIViewController.lens.title %~ { _ in Strings.project_view_button() }

    _ = self.contentView
      |> UIView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(5), left: Styles.grid(2),
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
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 14)
      |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
      |> UIButton.lens.accessibilityHint %~ {  _ in Strings.Opens_message_composer() }

    _ = self.viewMessagesButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.backer_modal_view_messages() }
      |> UIButton.lens.contentEdgeInsets .~ .init(all: Styles.grid(2))
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.accessibility_dashboard_buttons_messages_hint() }

    _ = self.dividerView
      |> UIView.lens.backgroundColor .~ .ksr_grey_500

    _ = [self.pledgeContainerView, self.rewardContainerView]
      ||> cardStyle(cornerRadius: 2.0)
      ||> UIView.lens.layer.borderColor .~ UIColor.ksr_grey_400.cgColor
      ||> UIView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.gridHalf(5), left: Styles.gridHalf(5),
                                                    bottom: Styles.gridHalf(5), right: Styles.grid(2))

    _ = self.totalPledgedLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 15)
      |> UILabel.lens.textColor .~ .black
      |> UILabel.lens.text %~ { _ in Strings.Total_pledged() }

    _ = self.totalPledgedAmountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 15)
      |> UILabel.lens.textColor .~ .black

    _ = self.pledgeLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Pledge() }

    _ = self.backerPledgeAmountLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.shippingLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.text %~ { _ in Strings.Shipping() }

    _ = self.shippingPlusLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.text .~ "+"

    _ = self.backerShippingAmountLabel
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

    _ = self.loadingIndicatorView
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.color .~ .ksr_navy_900

    _ = self.rewardSectionTitleLabel
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.rewardTitleWithAmountLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .black

    _ = self.backerRewardDescriptionLabel
      |> UILabel.lens.font .~ .ksr_caption1(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_navy_600

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
    if let nav = self.navigationController {
      for controller in nav.childViewControllers where controller is MessagesViewController {
        nav.popViewController(animated: true)
        return
      }
    }

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
