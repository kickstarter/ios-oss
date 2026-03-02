import UIKit

import KDS
/// Bottom sheet shown when the user taps the Share button.
///
/// This is a static placeholder that matches the intended layout:
/// - A “Share project” title
/// - A project preview card (image + title + creator)
/// - A grid of share targets (no-op for now)
final class VideoFeedShareProjectSheetViewController: UIViewController {
  private enum Constants {
    /// KDS surface token for bottom sheets.
    static let backgroundColor = KDS.Colors.Elevation.Surface.raised.uiColor()

    static let horizontalInset: CGFloat = 16
    static let topInset: CGFloat = 16
    static let sectionSpacing: CGFloat = 16

    static let titleText = "Share project"
    static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let titleColor = KDS.Colors.Text.primary.uiColor()

    static let gridRowSpacing: CGFloat = 12
    static let gridRowItemSpacing: CGFloat = 12
    static let gridItemCornerRadius: CGFloat = 10
    static let gridItemBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let gridItemTextColor = KDS.Colors.Text.Accent.green.uiColor()
    static let gridItemFont = UIFont.preferredFont(forTextStyle: .footnote)

    static let previewCornerRadius: CGFloat = 12
    static let previewBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let previewImageWidth: CGFloat = 110
    static let previewTextSpacing: CGFloat = 4
    static let previewImageTextSpacing: CGFloat = 12
    static let previewHorizontalInset: CGFloat = 12

    static let previewTitleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let previewCreatorFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static let previewCreatorColor = KDS.Colors.Text.secondary.uiColor()
  }

  /// Simple preview card shown at the top of the sheet.
  private let previewCard = VideoFeedProjectSharePreviewCardView()

  /// Placeholder grid of share targets.
  private let shareGrid = VideoFeedShareTargetsGridView()

  private let titleText: String
  private let creatorText: String
  private let imageURL: URL?

  init(titleText: String, creatorText: String, imageURL: URL?) {
    self.titleText = titleText
    self.creatorText = creatorText
    self.imageURL = imageURL
    super.init(nibName: nil, bundle: nil)

    modalPresentationStyle = .pageSheet
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Constants.backgroundColor
    view.layer.cornerRadius = 16
    view.layer.masksToBounds = true

    /// Matches the design: simple title at the top of the sheet.
    let titleLabel = UILabel()
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = Constants.titleText
    titleLabel.font = Constants.titleFont
    titleLabel.textColor = Constants.titleColor

    let container = UIStackView(arrangedSubviews: [titleLabel, previewCard, shareGrid])
    container.axis = .vertical
    container.spacing = Constants.sectionSpacing
    container.translatesAutoresizingMaskIntoConstraints = false
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

    self.previewCard.configure(title: self.titleText, creator: self.creatorText, imageURL: self.imageURL)
  }
}

// MARK: - Share sheet subviews

/// Simple card used in the share sheet header.
private final class VideoFeedProjectSharePreviewCardView: UIView {
  private enum Constants {
    static let backgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let cornerRadius: CGFloat = 12

    static let imageWidth: CGFloat = 110
    static let imageBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)

    static let imageTextSpacing: CGFloat = 12
    static let horizontalInset: CGFloat = 12

    static let titleFont = UIFont.preferredFont(forTextStyle: .headline)
    static let titleLines = 2

    static let creatorFont = UIFont.preferredFont(forTextStyle: .subheadline)
    static let creatorColor = KDS.Colors.Text.secondary.uiColor()
    static let textSpacing: CGFloat = 4
  }

  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let creatorLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  func configure(title: String, creator: String, imageURL _: URL?) {
    self.titleLabel.text = title
    self.creatorLabel.text = creator

    /// Placeholder image behavior for the spike.
    /// If we have a URL, show a generic photo glyph (no networking yet).
    self.imageView.image = UIImage(systemName: "photo")
    self.imageView.tintColor = KDS.Colors.Text.secondary.uiColor()
  }

  private func setUpView() {
    backgroundColor = Constants.backgroundColor
    layer.cornerRadius = Constants.cornerRadius
    clipsToBounds = true

    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.clipsToBounds = true
    self.imageView.backgroundColor = Constants.imageBackgroundColor

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.font = Constants.titleFont
    self.titleLabel.textColor = KDS.Colors.Text.primary.uiColor()
    self.titleLabel.numberOfLines = Constants.titleLines

    self.creatorLabel.translatesAutoresizingMaskIntoConstraints = false
    self.creatorLabel.font = Constants.creatorFont
    self.creatorLabel.textColor = Constants.creatorColor

    let textStack = UIStackView(arrangedSubviews: [titleLabel, creatorLabel])
    textStack.axis = .vertical
    textStack.spacing = Constants.textSpacing
    textStack.translatesAutoresizingMaskIntoConstraints = false

    addSubview(self.imageView)
    addSubview(textStack)

    NSLayoutConstraint.activate([
      self.imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.imageView.topAnchor.constraint(equalTo: topAnchor),
      self.imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      self.imageView.widthAnchor.constraint(equalToConstant: Constants.imageWidth),

      textStack.leadingAnchor.constraint(
        equalTo: self.imageView.trailingAnchor,
        constant: Constants.imageTextSpacing
      ),
      textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalInset),
      textStack.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}

/// Placeholder share target grid (tap does nothing for now).
private final class VideoFeedShareTargetsGridView: UIView {
  private enum Constants {
    static let stackSpacing: CGFloat = 12
    static let rowSpacing: CGFloat = 12
    static let rowCornerRadius: CGFloat = 10

    static let buttonFont = UIFont.preferredFont(forTextStyle: .footnote)
    static let buttonBackgroundColor = KDS.Colors.Background.Surface.raisedHigher.uiColor(opacity: 0.25)
    static let buttonTextColor = KDS.Colors.Text.Accent.green.uiColor()
  }

  private let stack = UIStackView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setUpView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  private func setUpView() {
    self.stack.axis = .vertical
    self.stack.spacing = Constants.stackSpacing
    self.stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(self.stack)

    NSLayoutConstraint.activate([
      self.stack.leadingAnchor.constraint(equalTo: leadingAnchor),
      self.stack.trailingAnchor.constraint(equalTo: trailingAnchor),
      self.stack.topAnchor.constraint(equalTo: topAnchor),
      self.stack.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    /// Two simple rows of placeholder buttons.
    self.stack.addArrangedSubview(self.makeRow(items: ["Copy link", "Feed", "X", "Stories"]))
    self.stack.addArrangedSubview(self.makeRow(items: ["Email", "More", "Messages", "WhatsApp"]))
  }

  private func makeRow(items: [String]) -> UIStackView {
    let row = UIStackView()
    row.axis = .horizontal
    row.distribution = .fillEqually
    row.spacing = Constants.rowSpacing

    for title in items {
      let button = UIButton(type: .system)
      button.setTitle(title, for: .normal)
      button.setTitleColor(Constants.buttonTextColor, for: .normal)
      button.titleLabel?.font = Constants.buttonFont
      button.backgroundColor = Constants.buttonBackgroundColor
      button.layer.cornerRadius = Constants.rowCornerRadius
      /// No-op; placeholder for the spike.
      button.addAction(UIAction { _ in }, for: .touchUpInside)
      row.addArrangedSubview(button)
    }

    return row
  }
}
