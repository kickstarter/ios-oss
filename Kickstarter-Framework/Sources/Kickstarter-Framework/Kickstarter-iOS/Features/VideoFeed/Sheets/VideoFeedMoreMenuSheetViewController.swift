import UIKit

/// Bottom sheet shown when the user taps the “…” button.
/// - “Not interested” opens the reasons sheet
/// - Everything else just dismisses the sheet for now
final class VideoFeedMoreMenuSheetViewController: VideoFeedBottomSheetViewController {
  var onNotInterestedTapped: (() -> Void)?
  var onDismissRequested: (() -> Void)?

  private let stack = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.stack.axis = .vertical
    self.stack.spacing = 8
    self.stack.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(self.stack)

    NSLayoutConstraint.activate([
      self.stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      self.stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      self.stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      self.stack.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -16
      )
    ])

    self.stack.addArrangedSubview(
      self.makeActionRowButton(title: "Not interested", systemImage: "eye.slash") { [weak self] in
        self?.onNotInterestedTapped?()
      }
    )

    self.stack.addArrangedSubview(
      self.makeActionRowButton(title: "More like this", systemImage: "face.smiling") { [weak self] in
        self?.onDismissRequested?()
      }
    )

    self.stack.addArrangedSubview(
      self.makeActionRowButton(title: "Share feedback", systemImage: "bubble.left") { [weak self] in
        self?.onDismissRequested?()
      }
    )

    self.stack.addArrangedSubview(
      self.makeActionRowButton(
        title: "Report",
        systemImage: "exclamationmark.octagon",
        tint: UIColor.systemRed
      ) { [weak self] in
        self?.onDismissRequested?()
      }
    )
  }
}
