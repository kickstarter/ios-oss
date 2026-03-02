import Foundation
import UIKit

// MARK: - Reusable pill

/// Small rounded pill used for the bottom overlay metadata.
public final class VideoFeedPillView: UIView {
  private let iconView = UIImageView()
  private let label = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(systemImage: String?, text: String) {
    if let systemImage {
      self.iconView.isHidden = false
      self.iconView.image = UIImage(systemName: systemImage)
    } else {
      self.iconView.isHidden = true
      self.iconView.image = nil
    }

    self.label.text = text
  }

  private func setUpView() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.backgroundColor = UIColor(white: 0.0, alpha: 0.35)
    self.layer.cornerRadius = 10
    self.layer.masksToBounds = true

    self.iconView.translatesAutoresizingMaskIntoConstraints = false
    self.iconView.tintColor = .systemGreen
    self.iconView.contentMode = .scaleAspectFit

    self.label.translatesAutoresizingMaskIntoConstraints = false
    self.label.textColor = .white
    self.label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
    self.label.setContentHuggingPriority(.required, for: .horizontal)
    self.label.setContentCompressionResistancePriority(.required, for: .horizontal)

    let stack = UIStackView(arrangedSubviews: [self.iconView, self.label])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 6

    addSubview(stack)

    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

      self.iconView.widthAnchor.constraint(equalToConstant: 14),
      self.iconView.heightAnchor.constraint(equalToConstant: 14)
    ])
  }
}
