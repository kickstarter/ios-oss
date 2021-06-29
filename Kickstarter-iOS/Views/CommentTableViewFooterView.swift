import Library
import Prelude
import UIKit

protocol CommentTableViewFooterViewDelegate: AnyObject {
  func commentTableViewFooterViewDidTapRetry(_ view: CommentTableViewFooterView)
}

final class CommentTableViewFooterView: UIView {
  // MARK: - Properties

  private let viewModel = CommentTableViewFooterViewModel()

  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    return indicator
  }()

  weak var delegate: CommentTableViewFooterViewDelegate?

  private lazy var retryButton = { UIButton(type: .custom) }()

  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.bindViewModel()
    self.configureViews()

    self.retryButton.addTarget(self, action: #selector(self.retryButtonTapped), for: .touchUpInside)

    self.activityIndicatorView.startAnimating()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Actions

  @objc func retryButtonTapped() {
    self.delegate?.commentTableViewFooterViewDidTapRetry(self)
  }

  // MARK: - Configuration

  func configureWith(value: CommentTableViewFooterViewState) {
    self.viewModel.inputs.configure(with: value)
  }

  private func configureViews() {
    _ = self
      |> \.backgroundColor .~ .ksr_white

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.activityIndicatorView, self.retryButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.activityIndicatorView.rac.hidden = self.viewModel.outputs.activityIndicatorHidden
    self.retryButton.rac.hidden = self.viewModel.outputs.retryButtonHidden
    self.rootStackView.rac.hidden = self.viewModel.outputs.rootStackViewHidden

    self.viewModel.outputs.bottomInsetHeight
      .observeForUI()
      .observeValues { [weak self] height in
        guard let self = self else { return }
        _ = self.rootStackView
          |> \.layoutMargins .~ .init(
            top: Styles.grid(2),
            left: Styles.grid(3),
            bottom: Styles.grid(height),
            right: Styles.grid(3)
          )
      }
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.retryButton
      |> retryButtonStyle
  }
}

// MARK: - Styles

private let retryButtonStyle: ButtonStyle = { button in
  button
    |> UIButton.lens.title(for: .normal) %~ { _ in
      Strings.Couldnt_load_more_comments_Tap_to_retry()
    }
    |> UIButton.lens.titleLabel.lineBreakMode .~ .byWordWrapping
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead()
    |> UIButton.lens.image(for: .normal) .~ Library.image(named: "circle-back")?
    .withRenderingMode(.alwaysTemplate)
    |> UIButton.lens.titleColor(for: .normal) .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.tintColor .~ UIColor.ksr_celebrate_700
    |> UIButton.lens.titleEdgeInsets .~ UIEdgeInsets(left: Styles.grid(1))
    |> UIButton.lens.contentVerticalAlignment .~ .top
    |> UIButton.lens.contentHorizontalAlignment .~ .left
}

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.isLayoutMarginsRelativeArrangement .~ true
}
