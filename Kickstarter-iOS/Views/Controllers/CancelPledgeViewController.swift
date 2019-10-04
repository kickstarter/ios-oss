import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class CancelPledgeViewController: UIViewController {
  private let viewModel: CancelPledgeViewModelType = CancelPledgeViewModel()

  // MARK: - Properties

  private lazy var cancelButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var cancellationDetailsTextLabel = { UILabel(frame: .zero) }()
  private lazy var cancellationReasonDisclaimerLabel = { UILabel(frame: .zero) }()
  private lazy var cancellationReasonTextField = { UITextField(frame: .zero) }()
  private lazy var goBackButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = { UIStackView(frame: .zero) }()
  private lazy var scrollView = { UIScrollView(frame: .zero) }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Cancel_pledge() }

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([
      self.cancellationDetailsTextLabel,
      self.cancellationReasonTextField,
      self.cancellationReasonDisclaimerLabel,
      self.cancelButton,
      self.goBackButton
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (self.cancellationReasonDisclaimerLabel, self.rootStackView)
      |> ksr_setCustomSpacing(Styles.grid(10))

    _ = (self.cancellationDetailsTextLabel, self.rootStackView)
      |> ksr_setCustomSpacing(Styles.grid(6))

    _ = (self.cancellationReasonTextField, self.rootStackView)
      |> ksr_setCustomSpacing(Styles.grid(1))

    self.setupConstraints()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(CancelPledgeViewController.dismissKeyboard))
    )

    self.goBackButton.addTarget(
      self, action: #selector(CancelPledgeViewController.goBackButtonTapped),
      for: .touchUpInside
    )

    self.viewModel.inputs.viewDidLoad()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    self.viewModel.inputs.traitCollectionDidChange()
  }

  // MARK: - Configuration

  internal func configure(with project: Project, backing: Backing) {
    self.viewModel.inputs.configure(with: project, backing: backing)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true
      |> \.showsVerticalScrollIndicator .~ false
      |> \.contentInset %~ { _ -> UIEdgeInsets in
        self.contentInsetsFor(traitCollection: self.traitCollection)
      }

    _ = self.rootStackView
      |> checkoutRootStackViewStyle
      |> \.spacing .~ Styles.grid(2)

    _ = self.cancellationDetailsTextLabel
      |> cancellationDetailsTextLabelStyle

    _ = self.cancellationReasonTextField
      |> cancellationReasonTextFieldStyle
      |> UITextField.lens.placeholder %~ { _ in Strings.Tell_us_why_optional() }

    _ = self.cancellationReasonDisclaimerLabel
      |> cancellationDisclaimerLabelStyle
      |> \.text %~ { _ in Strings.We_wont_share_this_with_the_creator() }

    _ = self.cancelButton
      |> redButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Yes_cancel_it() }

    _ = self.goBackButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.No_go_back() }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.popCancelPledgeViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      }

    self.cancellationDetailsTextLabel.rac.attributedText = self.viewModel.outputs
      .cancellationDetailsAttributedText

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        guard let self = self else { return }

        self.scrollView.handleKeyboardVisibilityDidChange(change, insets: self.scrollView.contentInset)
      }
  }

  // MARK: - Functions

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.cancelButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.goBackButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.cancellationReasonTextField.heightAnchor
        .constraint(greaterThanOrEqualTo: self.cancelButton.heightAnchor)
    ])
  }

  private func contentInsetsFor(traitCollection: UITraitCollection) -> UIEdgeInsets {
    return traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      ? .zero : .init(top: self.view.frame.height / 4)
  }

  // MARK: - Accessors

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  @objc private func goBackButtonTapped() {
    self.viewModel.inputs.goBackButtonTapped()
  }
}

// MARK: - Styles

private let cancellationDisclaimerLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ .ksr_caption1()
    |> \.textColor .~ UIColor.ksr_text_navy_600
    |> \.textAlignment .~ NSTextAlignment.center
    |> \.numberOfLines .~ 0
}

private let cancellationReasonTextFieldStyle: TextFieldStyle = { textField in
  textField
    |> formFieldStyle
    |> \.backgroundColor .~ UIColor.white
    |> \.borderStyle .~ UITextField.BorderStyle.roundedRect
}

private let cancellationDetailsTextLabelStyle: LabelStyle = { label in
  label
    |> \.textAlignment .~ NSTextAlignment.center
    |> \.numberOfLines .~ 0
}
