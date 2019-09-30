import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class CancelPledgeViewController: UIViewController {
  // MARK: - Properties
  private lazy var cancelButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var cancellationDetailsTextLabel = { UILabel(frame: .zero) }()
  private lazy var cancellationReasonTextField = { UITextField(frame: .zero) }()
  private lazy var cancellationReasonDisclaimerLabel = { UILabel(frame: .zero) }()
  private lazy var goBackButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var rootStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()
  private lazy var scrollView = { UIScrollView(frame: .zero) }()

  private let viewModel: CancelPledgeViewModelType = CancelPledgeViewModel()

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

    _ = ([self.cancellationDetailsTextLabel,
          self.cancellationReasonTextField,
          self.cancellationReasonDisclaimerLabel,
          self.cancelButton,
          self.goBackButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    // TODO: move this to a custom ksr function
    self.rootStackView.setCustomSpacing(Styles.grid(10), after: self.cancellationReasonDisclaimerLabel)
    self.rootStackView.setCustomSpacing(Styles.grid(6), after: self.cancellationDetailsTextLabel)
    self.rootStackView.setCustomSpacing(Styles.grid(1), after: self.cancellationReasonTextField)

    self.setupConstraints()

    self.view.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(CancelPledgeViewController.dismissKeyboard))
    )

    self.goBackButton.addTarget(self, action: #selector(CancelPledgeViewController.goBackButtonTapped),
                                for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Configuration

  internal func configure(with project: Project, backing: Backing) {
    self.viewModel.inputs.configure(with: project, backing: backing)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ UIColor.ksr_grey_400

    _ = self.scrollView
      |> \.alwaysBounceVertical .~ true

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
      |> apricotButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Yes_cancel_it() }

    _ = self.goBackButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.No_go_back() }
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.cancellationDetailsTextLabelValue
      .observeForUI()
      .observeValues { [weak self] amount, projectName in
        self?.setCancellationDetailsAttributedText(with: amount, projectName: projectName)
    }

    self.viewModel.outputs.popCancelPledgeViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.popViewController(animated: true)
    }

    Keyboard.change
      .observeForUI()
      .observeValues { [weak self] change in
        self?.scrollView.handleKeyboardVisibilityDidChange(change)
    }
  }

  // MARK: - Functions

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
      self.rootStackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
      self.rootStackView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor),
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.cancelButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.goBackButton.heightAnchor.constraint(equalToConstant: Styles.minTouchSize.height),
      self.cancellationReasonTextField.heightAnchor.constraint(equalTo: self.cancelButton.heightAnchor)
      ])
  }

  private func setCancellationDetailsAttributedText(with amount: String, projectName: String) {
    let fullString = Strings
      .Are_you_sure_you_wish_to_cancel_your_amount_pledge_to_project_name(amount: amount,
                                                                          project_name: projectName)
    let attributedString: NSMutableAttributedString = NSMutableAttributedString.init(string: fullString)
    let boldFontAttribute = [NSAttributedString.Key.font: UIFont.ksr_callout().bolded]
    let range1: NSRange = (fullString as NSString).localizedStandardRange(of: amount)
    let range2: NSRange = (fullString as NSString).localizedStandardRange(of: projectName)

    attributedString.addAttributes(boldFontAttribute, range: range1)
    attributedString.addAttributes(boldFontAttribute, range: range2)

    _ = self.cancellationDetailsTextLabel
      |> \.attributedText .~ attributedString
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
    |> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping
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
    |> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping
    |> \.textAlignment .~ NSTextAlignment.center
    |> \.numberOfLines .~ 0
}
