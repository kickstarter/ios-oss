import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48
    static let width: CGFloat = 98
  }
}

protocol ErroredBackingViewDelegate: class {
  func erroredBackingViewDidTapManage(_ view: ErroredBackingView, backing: GraphBacking)
}

final class ErroredBackingView: UIView {
  // MARK: - Properties

  public weak var delegate: ErroredBackingViewDelegate?
  private let backingInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let manageButton: UIButton = { UIButton(type: .custom) }()
  private let projectNameLabel: UILabel = { UILabel(frame: .zero) }()
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let viewModel: ErroredBackingViewViewModelType = ErroredBackingViewViewModel()

  // MARK: - Life cycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.manageButton.addTarget(self, action: #selector(self.manageButtonTapped), for: .touchUpInside)

    self.configureViews()
    self.configureConstraints()
    self.bindViewModel()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  // MARK: - Configuration

  func configureWith(value: GraphBacking) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = ([self.projectNameLabel], self.backingInfoStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.backingInfoStackView, self.manageButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()
  }

  private func configureConstraints() {
    NSLayoutConstraint.activate([
      self.manageButton.widthAnchor.constraint(equalToConstant: Layout.Button.width),
      self.manageButton.heightAnchor.constraint(equalToConstant: Layout.Button.height)
    ])
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.notifyDelegateManageButtonTapped
      .observeForUI()
      .observeValues { [weak self] backing in
        guard let self = self else { return }

        self.delegate?.erroredBackingViewDidTapManage(self, backing: backing)
      }
  }

  // MARK: - Actions

  @objc func manageButtonTapped() {
    self.viewModel.inputs.manageButtonTapped()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_300

    _ = self.backingInfoStackView
      |> backingInfoStackViewStyle

    _ = self.manageButton
      |> manageButtonStyle

    _ = self.manageButton.titleLabel
      ?|> manageButtonTitleLabelStyle

    _ = self.projectNameLabel
      |> projectNameLabelStyle

    _ = self.rootStackView
      |> rootStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
  }
}

// MARK: - Styles

private let backingInfoStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> verticalStackViewStyle
}

private let manageButtonStyle: ButtonStyle = { button in
  button
    |> redButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Manage() }
}

private let manageButtonTitleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.lineBreakMode .~ .byTruncatingTail
}

private let projectNameLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_footnote().bolded
    |> \.numberOfLines .~ 0
}

private func rootStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.alignment .~ .center
      |> \.axis .~ NSLayoutConstraint.Axis.horizontal
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(2), leftRight: Styles.grid(1))
      |> \.spacing .~ spacing
  }
}
