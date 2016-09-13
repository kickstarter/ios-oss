import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol ProjectFooterViewControllerDelegate: class {
  func projectFooterExpandDescription()
}

internal final class ProjectFooterViewController: UIViewController {
  private let viewModel: ProjectFooterViewModelType = ProjectFooterViewModel()
  internal weak var delegate: ProjectFooterViewControllerDelegate?

  @IBOutlet private weak var backedCountLabel: UILabel!
  @IBOutlet private weak var bottomPanelView: UIView!
  @IBOutlet private var bulletViews: [UILabel]!
  @IBOutlet private weak var categoryAndLocationStackView: UIStackView!
  @IBOutlet private weak var categoryButton: UIButton!
  @IBOutlet private weak var contactCreatorButton: UIButton!
  @IBOutlet private weak var createdByLabel: UILabel!
  @IBOutlet private weak var createdCountLabel: UILabel!
  @IBOutlet private weak var creatorButton: UIButton!
  @IBOutlet private weak var creatorImageView: UIImageView!
  @IBOutlet private weak var creatorInfoStackView: UIStackView!
  @IBOutlet private weak var creatorNameAndStatsStackView: UIStackView!
  @IBOutlet private weak var creatorNameLabel: UILabel!
  @IBOutlet private weak var creatorStackView: UIStackView!
  @IBOutlet private weak var creatorStatsStackView: UIStackView!
  @IBOutlet private weak var downArrowImageView: UIImageView!
  @IBOutlet private weak var keepReadingButton: UIButton!
  @IBOutlet private weak var keepReadingContainerView: UIView!
  @IBOutlet private weak var keepReadingLabel: UILabel!
  @IBOutlet private weak var keepReadingStackView: UIStackView!
  @IBOutlet private weak var locationButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var topGradientView: GradientView!
  @IBOutlet private weak var topPanelView: UIView!
  @IBOutlet private weak var updatesCountLabel: UILabel!

  internal func configureWith(project project: Project) {
    self.viewModel.inputs.configureWith(project: project)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.keepReadingButton.addTarget(self,
                                     action: #selector(keepReadingButtonTapped),
                                     forControlEvents: .TouchUpInside)

    self.contactCreatorButton.addTarget(self,
                                        action: #selector(contactCreatorButtonTapped),
                                        forControlEvents: .TouchUpInside)

    self.creatorButton.addTarget(self,
                                 action: #selector(creatorButtonTapped),
                                 forControlEvents: .TouchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // swiftlint:disable function_body_length
  override func bindStyles() {
    super.bindStyles()

    self.topGradientView.setGradient([
      (UIColor(white: 1, alpha: 0), 0.0),
      (UIColor(white: 1, alpha: 1), 1.0)
    ])

    self.topPanelView
      |> UIView.lens.backgroundColor .~ .ksr_grey_100

    self.bottomPanelView
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    self.createdByLabel
      |> UILabel.lens.font .~ UIFont.ksr_subhead().bolded
      |> UILabel.lens.textColor .~ .ksr_text_navy_900
      |> UILabel.lens.text %~ { _ in Strings.project_menu_created_by() }

    self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_title3(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    [self.createdCountLabel, self.backedCountLabel, self.updatesCountLabel]
      ||> UILabel.lens.font .~ .ksr_headline(size: 13)
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500

    self.bulletViews
      ||> UILabel.lens.textColor .~ .ksr_text_navy_500

    self.updatesCountLabel
      |> UILabel.lens.textColor .~ .ksr_text_green_700

    self.creatorStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    self.creatorInfoStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.alignment .~ .Center

    self.creatorNameAndStatsStackView
      |> UIStackView.lens.spacing .~ 0

    self.creatorStatsStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.contactCreatorButton
      |> contactCreatorButtonStyle
      |> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "ask-me-anything-icon", inBundle: .framework, compatibleWithTraitCollection: nil)

    self.categoryButton
      |> categoryLocationButtonStyle
      |> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "category-icon", inBundle: .framework, compatibleWithTraitCollection: nil)

    self.locationButton
      |> categoryLocationButtonStyle
      |> UIButton.lens.image(forState: .Normal)
        .~ UIImage(named: "location-icon", inBundle: .framework, compatibleWithTraitCollection: nil)

    [self.creatorStackView, self.categoryAndLocationStackView]
      ||> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(2))
      ||> UIStackView.lens.layoutMarginsRelativeArrangement .~ true

    self.keepReadingStackView
      |> UIStackView.lens.userInteractionEnabled .~ false
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(4), leftRight: 0)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    self.keepReadingLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.text %~ { _ in Strings.Keep_reading() }

    self.downArrowImageView
      |> UIImageView.lens.tintColor .~ self.keepReadingLabel.textColor

    self.keepReadingButton
      |> UIButton.lens.backgroundColor(forState: .Normal) .~ .whiteColor()
      |> UIButton.lens.backgroundColor(forState: .Highlighted) .~ .ksr_grey_200

    self.separatorViews
      ||> separatorStyle
  }
  // swiftlint:enable function_body_length

  override func bindViewModel() {
    super.bindViewModel()

    self.keepReadingContainerView.rac.hidden = self.viewModel.outputs.keepReadingHidden
    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorNameLabelText
    self.createdCountLabel.rac.text = self.viewModel.outputs.createdProjectsLabelText
    self.backedCountLabel.rac.text = self.viewModel.outputs.backedProjectsLabelText
    self.updatesCountLabel.rac.text = self.viewModel.outputs.updatesLabelText
    self.categoryButton.rac.title = self.viewModel.outputs.categoryButtonTitle
    self.locationButton.rac.title = self.viewModel.outputs.locationButtonTitle

    self.viewModel.outputs.creatorImageUrl
      .observeForControllerAction()
      .on(next: { [weak self] _ in
        self?.creatorImageView.image = nil
      })
      .ignoreNil()
      .observeNext { [weak self] in
        self?.creatorImageView.af_setImageWithURL($0)
    }

    self.viewModel.outputs.notifyDelegateToExpandDescription
      .observeNext { [weak self] in
        self?.delegate?.projectFooterExpandDescription()
    }

    self.viewModel.outputs.goToMessageCreator
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToMessageCreator(forProject: $0) }

    self.viewModel.outputs.goToCreatorBio
      .observeForControllerAction()
      .observeNext { [weak self] in self?.goToCreatorBio(forProject: $0) }
  }

  @objc private func keepReadingButtonTapped() {
    self.viewModel.inputs.keepReadingButtonTapped()
  }

  @objc private func contactCreatorButtonTapped() {
    self.viewModel.inputs.contactCreatorButtonTapped()
  }

  @objc private func creatorButtonTapped() {
    self.viewModel.inputs.creatorButtonTapped()
  }

  private func goToMessageCreator(forProject project: Project) {
    let vc = MessageDialogViewController
      .configuredWith(messageSubject: .project(project), context: .projectPage)
    vc.modalPresentationStyle = .FormSheet
    vc.delegate = self
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func goToCreatorBio(forProject project: Project) {
    let vc = ProjectCreatorViewController()
    vc.configureWith(project: project)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension ProjectFooterViewController: MessageDialogViewControllerDelegate {
  internal func messageDialogWantsDismissal(dialog: MessageDialogViewController) {
    dialog.dismissViewControllerAnimated(true, completion: nil)
  }

  internal func messageDialog(dialog: MessageDialogViewController, postedMessage message: Message) {
  }
}
