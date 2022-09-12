import Foundation
import Library
import Prelude
import ReactiveSwift
import UIKit

public final class SetYourPasswordViewController: UIViewController {
  // MARK: - Properties

  private lazy var contextLabel = { UILabel(frame: .zero) }()
  private lazy var newPasswordLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var newPasswordTextField: UITextField = { UITextField(frame: .zero) |> \.tag .~ 0 }()
  private lazy var confirmPasswordLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var confirmPasswordTextField: UITextField = { UITextField(frame: .zero) |> \.tag .~ 1 }()

  private lazy var rootStackView = { UIStackView() }()
  private lazy var scrollView = {
    UIScrollView(frame: .zero)
      |> \.alwaysBounceVertical .~ true

  }()

  private lazy var saveButton = { UIButton(type: .custom)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  fileprivate lazy var keyboardDimissingTapGestureRecognizer: UITapGestureRecognizer = {
    UITapGestureRecognizer(
      target: self,
      action: #selector(SetYourPasswordViewController.dismissKeyboard)
    )
      |> \.cancelsTouchesInView .~ false
  }()

  private let viewModel: SetYourPasswordViewModelType = SetYourPasswordViewModel()

  // MARK: - Configuration

  public static func configuredWith(
    userEmail: String
  ) -> SetYourPasswordViewController {
    let vc = SetYourPasswordViewController.instantiate()
    vc.viewModel.inputs.configureWith(userEmail)
    return vc
  }

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.title = "Set your password"

    self.view.addGestureRecognizer(self.keyboardDimissingTapGestureRecognizer)

    self.configureViews()
    self.setupConstraints()
    self.configureTargets()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  public override func bindStyles() {
    super.bindStyles()

    _ = self.contextLabel
      |> contextLabelStyle

    _ = self.rootStackView
      |> baseStackViewStyle
      |> loginRootStackViewStyle

    _ = self.newPasswordLabel
      |> textFieldLabelStyle

    _ = self.confirmPasswordLabel
      |> textFieldLabelStyle

    _ = self.newPasswordTextField
      |> textFieldStyle
      |> \.accessibilityLabel .~ self.newPasswordLabel.text
      |> \.attributedPlaceholder %~ { _ in settingsAttributedPlaceholder("") }

    _ = self.confirmPasswordTextField
      |> textFieldStyle
      |> \.accessibilityLabel .~ self.confirmPasswordLabel.text
      |> \.attributedPlaceholder %~ { _ in settingsAttributedPlaceholder("") }

    _ = self.saveButton
      |> savePasswordButtonStyle
      |> \.isEnabled .~ false
  }

  // MARK: - Bind View Model

  public override func bindViewModel() {
    self.contextLabel.rac.text = self.viewModel.outputs.contextLabelText
    self.newPasswordLabel.rac.text = self.viewModel.outputs.newPasswordLabel
    self.confirmPasswordLabel.rac.text = self.viewModel.outputs.confirmPasswordLabel
    self.saveButton.rac.enabled = self.viewModel.outputs.saveButtonIsEnabled
  }

  // MARK: - Functions

  private func configureViews() {
    _ = self.view
      |> \.autoresizingMask .~ .flexibleHeight
      |> \.backgroundColor .~ .ksr_white
      |> \.clipsToBounds .~ true

    _ = (self.scrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.scrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([
      self.contextLabel,
      self.newPasswordLabel,
      self.newPasswordTextField,
      self.confirmPasswordLabel,
      self.confirmPasswordTextField,
      self.saveButton
    ], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.rootStackView.setCustomSpacing(Styles.grid(7), after: self.contextLabel)
    self.rootStackView.setCustomSpacing(Styles.grid(3), after: self.confirmPasswordTextField)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.newPasswordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      self.confirmPasswordTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
      self.saveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
    ])
  }

  private func configureTargets() {
    self.newPasswordTextField
      .addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    self.confirmPasswordTextField
      .addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    self.saveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchUpInside)
  }

  // MARK: - Accessors

  @objc private func dismissKeyboard() {
    self.view.endEditing(true)
  }

  @objc private func textFieldDidChange(_ textField: UITextField) {
    guard let password = textField.text else { return }

    switch textField.tag {
    case 0:
      self.viewModel.inputs.newPasswordFieldDidChange(password)
    case 1:
      self.viewModel.inputs.confirmPasswordFieldDidChange(password)
    default:
      return
    }
  }

  @objc private func saveButtonPressed() {
    self.viewModel.inputs.saveButtonPressed()
  }
}

// MARK: - Extensions

extension SetYourPasswordViewController: UITextFieldDelegate {
  public func textFieldDidEndEditing(_ textField: UITextField) {
    guard let password = textField.text else { return }

    switch textField.tag {
    case 0:
      self.viewModel.inputs.newPasswordFieldDidReturn(newPassword: password)
    case 1:
      self.viewModel.inputs.confirmPasswordFieldDidReturn(confirmPassword: password)
    default:
      return
    }
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
