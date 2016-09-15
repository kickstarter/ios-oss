import KsApi
import Library
import Prelude
import Prelude_UIKit
import UIKit

internal protocol CommentsEmptyStateCellDelegate: class {
  /// Call when we should navigate to the comment dialog.
  func commentEmptyStateCellGoToCommentDialog()

  /// Call when we should navigate to the login tout.
  func commentEmptyStateCellGoToLoginTout()
}

internal final class CommentsEmptyStateCell: UITableViewCell, ValueCell {
  internal weak var delegate: CommentsEmptyStateCellDelegate?
  private let viewModel: CommentsEmptyStateCellViewModelType = CommentsEmptyStateCellViewModel()

  @IBOutlet private weak var leaveACommentButton: UIButton!
  @IBOutlet private weak var loginButton: UIButton!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var subtitleLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal override func awakeFromNib() {
    super.awakeFromNib()

    self.leaveACommentButton.addTarget(self,
                                       action: #selector(leaveACommentTapped),
                                       forControlEvents: .TouchUpInside)

    self.loginButton.addTarget(self, action: #selector(loginTapped), forControlEvents: .TouchUpInside)
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> CommentsEmptyStateCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(9), leftRight: Styles.grid(3))

    self.leaveACommentButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in
        Strings.project_comments_empty_state_backer_button()
    }
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.general_navigation_buttons_comment() }
      |> UIButton.lens.accessibilityHint %~ { _ in
        Strings.accessibility_dashboard_buttons_post_update_hint()
    }

    self.loginButton
      |> borderButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.login_buttons_log_in() }

    self.rootStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(5)

    self.subtitleLabel
      |> UILabel.lens.font .~ .ksr_body(size: 16.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.textAlignment .~ .Center

    self.titleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 18.0)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.project_comments_empty_state_backer_title() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleText
    self.loginButton.rac.hidden = self.viewModel.outputs.loginButtonHidden
    self.leaveACommentButton.rac.hidden = self.viewModel.outputs.leaveACommentButtonHidden

    self.viewModel.outputs.goToCommentDialog
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.commentEmptyStateCellGoToCommentDialog() }

    self.viewModel.outputs.goToLoginTout
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.commentEmptyStateCellGoToLoginTout() }
  }

  internal func configureWith(value value: (Project, Update?)) {
    self.viewModel.inputs.configureWith(project: value.0, update: value.1)
  }

  @objc private func loginTapped() {
    self.viewModel.inputs.loginTapped()
  }

  @objc private func leaveACommentTapped() {
    self.viewModel.inputs.leaveACommentTapped()
  }
}
