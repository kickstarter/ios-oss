import UIKit

/// Confirmation toast shown after the user takes an action like “Not interested” or “More like this”.
/// Animates in from the top, sits under the status bar, and supports an optional “Undo” action.
final class VideoFeedConfirmationToastView: UIView {
  struct ViewModel {
    let message: String
    let undoTapped: (() -> Void)?
  }

  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
  private let iconView = UIImageView()
  private let messageLabel = UILabel()
  private let undoButton = UIButton(type: .system)

  private var undoTapped: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(with viewModel: ViewModel) {
    self.undoTapped = viewModel.undoTapped
    self.messageLabel.text = viewModel.message
  }

  // MARK: - Private

  private func setUpView() {
    self.translatesAutoresizingMaskIntoConstraints = false

    self.blurView.translatesAutoresizingMaskIntoConstraints = false
    self.blurView.clipsToBounds = true
    self.blurView.layer.cornerRadius = 12

    addSubview(self.blurView)

    NSLayoutConstraint.activate([
      self.blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.blurView.topAnchor.constraint(equalTo: topAnchor),
      self.blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    self.iconView.translatesAutoresizingMaskIntoConstraints = false
    self.iconView.image = UIImage(systemName: "checkmark")
    self.iconView.tintColor = .systemGreen

    self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
    self.messageLabel.font = .preferredFont(forTextStyle: .subheadline)
    self.messageLabel.textColor = .white
    self.messageLabel.numberOfLines = 2

    var undoConfig = UIButton.Configuration.plain()
    undoConfig.title = "Undo"
    undoConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
    self.undoButton.configuration = undoConfig
    self.undoButton.translatesAutoresizingMaskIntoConstraints = false
    self.undoButton.setTitleColor(.white, for: .normal)

    self.undoButton.addAction(UIAction { [weak self] _ in
      self?.undoTapped?()
    }, for: .touchUpInside)

    let content = UIStackView(arrangedSubviews: [self.iconView, self.messageLabel, UIView(), self.undoButton])
    content.axis = .horizontal
    content.alignment = .center
    content.spacing = 10
    content.translatesAutoresizingMaskIntoConstraints = false

    self.blurView.contentView.addSubview(content)

    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: self.blurView.contentView.leadingAnchor, constant: 12),
      content.trailingAnchor.constraint(equalTo: self.blurView.contentView.trailingAnchor, constant: -8),
      content.topAnchor.constraint(equalTo: self.blurView.contentView.topAnchor, constant: 10),
      content.bottomAnchor.constraint(equalTo: self.blurView.contentView.bottomAnchor, constant: -10),

      self.iconView.widthAnchor.constraint(equalToConstant: 18),
      self.iconView.heightAnchor.constraint(equalToConstant: 18)
    ])
  }
}
