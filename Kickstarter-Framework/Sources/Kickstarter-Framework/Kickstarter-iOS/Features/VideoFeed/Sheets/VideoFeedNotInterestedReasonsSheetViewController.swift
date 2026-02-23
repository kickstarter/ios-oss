import UIKit

/// Bottom sheet shown when tapping “Not interested” that lets the user pick a reason.
final class VideoFeedNotInterestedReasonsSheetViewController: VideoFeedBottomSheetViewController {
  var onReasonSelected: ((String) -> Void)?

  private let titleLabel = UILabel()
  private let stack = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.text = "Tell us why you’re not interested"
    self.titleLabel.font = .preferredFont(forTextStyle: .headline)

    self.stack.axis = .vertical
    self.stack.spacing = 8
    self.stack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(self.titleLabel)
    view.addSubview(self.stack)

    NSLayoutConstraint.activate([
      self.titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      self.titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      self.titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),

      self.stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      self.stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      self.stack.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 12),
      self.stack.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -16
      )
    ])

    [
      "Not relevant to me",
      "Not something I’d support",
      "Misleading",
      "Other"
    ].forEach { reason in
      self.stack.addArrangedSubview(
        self.makeSelectionRowButton(title: reason, systemImage: "circle") { [weak self] in
          self?.onReasonSelected?(reason)
        }
      )
    }
  }
}
