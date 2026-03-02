import UIKit

import KDS
/// Bottom sheet shown after “Not interested”.
///
/// This is a static placeholder that lets the user pick a reason.
/// We don’t persist anything yet; selecting a reason just calls the callback.
final class VideoFeedNotInterestedReasonsSheetViewController: UIViewController {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Elevation.Surface.raised.uiColor()
    static let horizontalInset: CGFloat = 16
    static let topInset: CGFloat = 16
    static let sectionSpacing: CGFloat = 12

    static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let titleColor = KDS.Colors.Text.primary.uiColor()

    static let rowSpacing: CGFloat = 10
    static let rowCornerRadius: CGFloat = 14
    static let rowHeight: CGFloat = 48
    static let rowBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let rowTextColor = KDS.Colors.Text.primary.uiColor()

    /// Radio icon
    static let circleImageName = "circle"
    static let circleTintColor = KDS.Colors.Text.secondary.uiColor()
    static let rowContentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    static let rowImagePadding: CGFloat = 12
  }

  /// Called when a reason is selected.
  var onReasonSelected: ((String) -> Void)?

  private let titleLabel = UILabel()
  private let stack = UIStackView()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = 16
    view.layer.masksToBounds = true

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.text = "Tell us why you’re not interested"
    self.titleLabel.font = Constants.titleFont
    self.titleLabel.textColor = Constants.titleColor

    self.stack.translatesAutoresizingMaskIntoConstraints = false
    self.stack.axis = .vertical
    self.stack.spacing = Constants.rowSpacing

    let container = UIStackView(arrangedSubviews: [titleLabel, stack])
    container.translatesAutoresizingMaskIntoConstraints = false
    container.axis = .vertical
    container.spacing = Constants.sectionSpacing
    view.addSubview(container)

    NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
      container.topAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.topAnchor,
        constant: Constants.topInset
      ),
      /// Allow the sheet to hug its content instead of forcing a full-height layout.
      container.bottomAnchor.constraint(
        lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -Constants.topInset
      )
    ])

    let reasons = [
      "Not relevant to me",
      "Not something I’d support",
      "Misleading",
      "Other"
    ]

    for reason in reasons {
      self.stack.addArrangedSubview(self.makeRow(title: reason) { [weak self] in
        self?.onReasonSelected?(reason)
      })
    }
  }

  private func makeRow(title: String, action: @escaping () -> Void) -> UIView {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false

    /// Match the design: left-aligned rows with a leading circle icon.
    button.contentHorizontalAlignment = .leading

    var config = UIButton.Configuration.plain()
    config.title = title
    config.image = UIImage(systemName: Constants.circleImageName)
    config.imagePlacement = .leading
    config.imagePadding = Constants.rowImagePadding
    config.contentInsets = Constants.rowContentInsets

    config.baseForegroundColor = Constants.rowTextColor
    config.imageColorTransformer = UIConfigurationColorTransformer { _ in
      Constants.circleTintColor
    }
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming

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
