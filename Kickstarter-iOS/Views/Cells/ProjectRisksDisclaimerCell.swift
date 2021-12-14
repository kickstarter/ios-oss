import KsApi
import Library
import Prelude
import UIKit

protocol ProjectRisksDisclaimerCellDelegate: AnyObject {
  func projectRisksDisclaimerCell(_ cell: ProjectRisksDisclaimerCell, didTapURL: URL)
}

final class ProjectRisksDisclaimerCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  weak var delegate: ProjectRisksDisclaimerCellDelegate?
  private let viewModel = ProjectRisksDisclaimerCellViewModel()

  private lazy var descriptionLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.bindStyles()
    self.configureViews()
    self.bindViewModel()

    let descriptionLabelTapGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(self.descriptionLabelTapped)
    )
    self.descriptionLabel.addGestureRecognizer(descriptionLabelTapGesture)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Bindings

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateDescriptionLabelTapped
      .observeForControllerAction()
      .observeValues { [weak self] url in
        guard let self = self else { return }
        self.delegate?.projectRisksDisclaimerCell(self, didTapURL: url)
      }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> \.separatorInset .~ .init(leftRight: Styles.projectPageLeftRightInset)

    _ = self.contentView
      |> \.layoutMargins .~
      .init(topBottom: Styles.projectPageTopBottomInset, leftRight: Styles.projectPageLeftRightInset)

    _ = self.descriptionLabel
      |> descriptionLabelStyle
      |> \.attributedText .~ self.attributedTextForFootnoteLabel()

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  // MARK: - Configuration

  func configureWith(value _: Void) {
    return
  }

  private func configureViews() {
    _ = (self.rootStackView, self.contentView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.descriptionLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Helpers

  private func attributedTextForFootnoteLabel() -> NSAttributedString {
    let attributes: String.Attributes = [
      .font: UIFont.ksr_subhead(),
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    return NSMutableAttributedString(
      string: Strings.Learn_about_accountability_on_Kickstarter(),
      attributes: attributes
    )
  }

  // MARK: - Actions

  @objc private func descriptionLabelTapped() {
    guard let url = HelpType.trust
      .url(withBaseUrl: AppEnvironment.current.apiService.serverConfig.webBaseUrl) else { return }
    self.viewModel.inputs.descriptionLabelTapped(url: url)
  }
}

// MARK: - Styles

private let descriptionLabelStyle: LabelStyle = { label in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.isUserInteractionEnabled .~ true
    |> \.lineBreakMode .~ .byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.textColor .~ .ksr_create_700
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ .vertical
    |> \.insetsLayoutMarginsFromSafeArea .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.grid(3)
}
