import Foundation
import Library
import Prelude
import ReactiveSwift
import UIKit

public final class FacebookResetPasswordViewController: UIViewController {
  // MARK: - Properties

  private lazy var contextLabel = { UILabel(frame: .zero) }()
  private lazy var emailLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var emailTextField: UITextField = { UITextField(frame: .zero) }()

  private lazy var loadingIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView()
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView = { UIStackView() }()
  private lazy var scrollView = {
    UIScrollView(frame: .zero)
      |> \.alwaysBounceVertical .~ true
      |> \.showsVerticalScrollIndicator .~ false

  }()

  private lazy var setPasswordButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  fileprivate lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(FacebookResetPasswordViewController.dismissKeyboard)
    )
      |> \.cancelsTouchesInView .~ false
  }()

  private let viewModel: FacebookResetPasswordViewModelType = FacebookResetPasswordViewModel()

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.title = Strings.Set_new_password()

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureViews()
    self.setupConstraints()
    self.configureTargets()

    self.viewModel.inputs.viewDidLoad()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear()
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.contextLabel
      |> contextLabelStyle

    _ = self.rootStackView
      |> baseStackViewStyle
      |> loginRootStackViewStyle

    _ = self.emailLabel
      |> textFieldLabelStyle

    _ = self.emailTextField
      |> emailFieldStyle
      |> UITextField.lens.returnKeyType .~ .go
      |> roundedStyle(cornerRadius: Styles.grid(2))
      |> \.borderStyle .~ UITextField.BorderStyle.roundedRect
      |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
      |> \.layer.borderWidth .~ 1
      |> \.accessibilityLabel .~ self.emailLabel.text

    self.emailTextField.attributedPlaceholder = settingsAttributedPlaceholder("")

    _ = self.setPasswordButton
      |> resetPasswordButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.Set_new_password()
      }
      |> \.isEnabled .~ false
  }

  // MARK: - Bind View Model

  public override func bindViewModel() {
    super.bindViewModel()

    self.loadingIndicator.rac.animating = self.viewModel.outputs.shouldShowActivityIndicator
    self.contextLabel.rac.text = self.viewModel.outputs.contextLabelText
    self.emailLabel.rac.text = self.viewModel.outputs.emailLabel
    self.setPasswordButton.rac.enabled = self.viewModel.outputs.setPasswordButtonIsEnabled

    self.viewModel.outputs.setPasswordFailure
      .observeForControllerAction()
      .observeValues { [weak self] errorMessage in
        self?.present(UIAlertController.genericError(errorMessage), animated: true, completion: nil)
        self?.enableTextFieldsAndSaveButton(true)
      }

    self.viewModel.outputs.setPasswordSuccess
      .observeForControllerAction()
      .observeValues { [weak self] successMessage in
        self?.present(UIAlertController.alert(message: successMessage), animated: true)
        self?.enableTextFieldsAndSaveButton(true)
      }

    self.viewModel.outputs.textFieldAndSetPasswordButtonAreEnabled
      .observeForUI()
      .observeValues { [weak self] isEnabled in
        self?.enableTextFieldsAndSaveButton(isEnabled)
      }

    Keyboard.change.observeForUI()
      .observeValues { [weak self] in self?.animateTextViewConstraint($0) }
  }

  // MARK: - Functions

  private func configureViews() {
    _ = self.view
      |> \.backgroundColor .~ .ksr_white

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([
      self.contextLabel,
      self.emailLabel,
      self.emailTextField,
      self.setPasswordButton,
      self.loadingIndicator
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.rootStackView.setCustomSpacing(Styles.grid(7), after: self.contextLabel)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),

      self.emailTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

      self.setPasswordButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
    ])
  }

  private func configureTargets() {
    self.emailTextField
      .addTarget(
        self,
        action: #selector(self.emailTextFieldDidChange(_:)),
        for: [.editingChanged, .editingDidEndOnExit]
      )
    self.emailTextField
      .addTarget(self, action: #selector(self.emailTextFieldReturn(_:)), for: .editingDidEndOnExit)

    self.setPasswordButton
      .addTarget(self, action: #selector(self.setPasswordButtonPressed), for: .touchUpInside)
  }

  private func enableTextFieldsAndSaveButton(_ isEnabled: Bool) {
    _ = [self.emailTextField, self.setPasswordButton]
      ||> \.isUserInteractionEnabled .~ isEnabled

    self.setPasswordButton.isHidden = !isEnabled
  }

  private func animateTextViewConstraint(_ change: Keyboard.Change) {
    UIView.animate(withDuration: change.duration, delay: 0.0, options: change.options, animations: {
      self.scrollView.contentInset.bottom = change.frame.height
    }, completion: nil)
  }

  // MARK: - Accessors

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  @objc private func emailTextFieldDidChange(_ textField: UITextField) {
    guard let email = textField.text else { return }

    self.viewModel.inputs.emailTextFieldFieldDidChange(email)
  }

  @objc internal func emailTextFieldReturn(_: UITextField) {
    self.viewModel.inputs.emailTextFieldFieldDidReturn()
  }

  @objc private func setPasswordButtonPressed() {
    self.viewModel.inputs.setPasswordButtonPressed()
  }
}

// MARK: - Styles

private let baseStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.distribution .~ .fill
    |> \.alignment .~ .fill
    |> \.axis .~ .vertical
    |> UIStackView.lens.spacing .~ Styles.grid(2)
}

private let contextLabelStyle: LabelStyle = { label in
  label
    |> \.textAlignment .~ NSTextAlignment.left
    |> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping
    |> \.numberOfLines .~ 0
    |> UILabel.lens.font %~ { _ in UIFont.ksr_body(size: 16) }
}

private let textFieldLabelStyle: LabelStyle = { label in
  label
    |> \.textAlignment .~ NSTextAlignment.left
    |> \.lineBreakMode .~ NSLineBreakMode.byWordWrapping
    |> \.numberOfLines .~ 0
    |> \.backgroundColor .~ .ksr_white
    |> \.textColor .~ UIColor.ksr_support_700
    |> \.font %~ { _ in .ksr_callout(size: 13) }
}

private let textFieldStyle: TextFieldStyle = { textField in
  textField
    |> settingsNewPasswordFormFieldAutoFillStyle
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> UITextField.lens.textColor .~ .ksr_black
    |> UITextField.lens.font %~ { _ in UIFont.ksr_body(size: 13) }
    |> \.textAlignment .~ .left
    |> \.borderStyle .~ UITextField.BorderStyle.roundedRect
    |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor
    |> \.layer.borderWidth .~ 1
    |> \.returnKeyType .~ .done
}

private let savePasswordButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> roundedStyle(cornerRadius: Styles.grid(2))
    |> UIButton.lens.backgroundColor(for: .disabled) .~ UIColor.ksr_support_300.mixLighter(0.12)
    |> UIButton.lens.title(for: .normal) %~ { _ in
      Strings.Save()
    }
}
