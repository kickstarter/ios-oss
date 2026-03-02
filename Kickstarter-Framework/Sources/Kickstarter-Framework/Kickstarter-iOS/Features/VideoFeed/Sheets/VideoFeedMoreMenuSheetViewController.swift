import UIKit

import KDS
/// Bottom sheet shown when the user taps the “…” button.
///
/// This is a static placeholder menu:
/// - “Not interested” opens the reasons sheet
/// - Everything else just dismisses the sheet for now
final class VideoFeedMoreMenuSheetViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Elevation.Surface.raised.uiColor()
    static let horizontalInset: CGFloat = 16
    static let topInset: CGFloat = 16
    static let rowSpacing: CGFloat = 12
    static let rowCornerRadius: CGFloat = 14
    static let rowHeight: CGFloat = 48

    static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let rowFont = UIFont.preferredFont(forTextStyle: .body)

    static let textColor = KDS.Colors.Text.primary.uiColor()
    static let secondaryTextColor = KDS.Colors.Text.secondary.uiColor()

    static let rowBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let reportTint = KDS.Colors.Text.Accent.red.uiColor()

    /// Layout
    static let rowContentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    static let rowImagePadding: CGFloat = 12
  }

  /// Called when “Not interested” is tapped.
  var onNotInterestedTapped: (() -> Void)?

  /// Called when “More like this” is tapped.
  var onMoreLikeThisTapped: (() -> Void)?

  /// Called when any other item should dismiss the menu.
  var onDismissRequested: (() -> Void)?

  private let stack = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = 16
    view.layer.masksToBounds = true

    self.stack.axis = .vertical
    self.stack.spacing = Constants.rowSpacing
    self.stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(self.stack)

    NSLayoutConstraint.activate([
      self.stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
      self.stack.trailingAnchor.constraint(
        equalTo: view.trailingAnchor,
        constant: -Constants.horizontalInset
      ),
      self.stack.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: Constants.topInset
      ),
      /// Allow the sheet to hug its content instead of forcing a full-height layout.
      self.stack.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -Constants.topInset
      )
    ])

    self.stack
      .addArrangedSubview(self.makeRow(title: "Not interested", systemImage: "eye.slash") { [weak self] in
        self?.onNotInterestedTapped?()
      })

    self.stack
      .addArrangedSubview(self.makeRow(title: "More like this", systemImage: "face.smiling") { [weak self] in
        self?.onMoreLikeThisTapped?()
      })

    self.stack
      .addArrangedSubview(self.makeRow(title: "Share feedback", systemImage: "bubble.left") { [weak self] in
        self?.onDismissRequested?()
      })

    self.stack.addArrangedSubview(self.makeRow(
      title: "Report",
      systemImage: "exclamationmark.octagon",
      tint: Constants.reportTint
    ) { [weak self] in
      self?.onDismissRequested?()
    })
  }

  private func makeRow(
    title: String,
    systemImage: String,
    tint: UIColor? = nil,
    action: @escaping () -> Void
  ) -> UIView {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false

    /// Match the design: rows are left-aligned, not centered.
    button.contentHorizontalAlignment = .leading

    var config = UIButton.Configuration.plain()
    config.title = title
    config.image = UIImage(systemName: systemImage)
    config.imagePlacement = .leading
    config.imagePadding = Constants.rowImagePadding
    config.contentInsets = Constants.rowContentInsets

    config.baseForegroundColor = tint ?? Constants.textColor
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = Constants.rowFont

      /// Force a left-aligned title even when the button expands full width.
      let paragraph = NSMutableParagraphStyle()
      paragraph.alignment = .left
      outgoing.paragraphStyle = paragraph

      return outgoing
    }

    button.configuration = config

    button.backgroundColor = Constants.rowBackgroundColor
    button.layer.cornerRadius = Constants.rowCornerRadius

    button.addAction(UIAction { _ in action() }, for: .touchUpInside)

    NSLayoutConstraint.activate([
      button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.rowHeight)
    ])

    return button
  }
}
