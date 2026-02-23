import UIKit

/// Shared base class for Video Feed bottom sheets.
class VideoFeedBottomSheetViewController: UIViewController {
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    modalPresentationStyle = .pageSheet
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    self.configureSheetPresentation()
    self.updatePreferredContentSizeToFit()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.updatePreferredContentSizeToFit()
    self.sheetPresentationController?.invalidateDetents()
  }

  // MARK: - Sheet presentation

  private func configureSheetPresentation() {
    guard let sheet = sheetPresentationController else { return }

    sheet.prefersGrabberVisible = true
    sheet.preferredCornerRadius = 16
    sheet.prefersScrollingExpandsWhenScrolledToEdge = false

    let id = UISheetPresentationController.Detent.Identifier("preferredContentSizeHeight")
    sheet.detents = [
      .custom(identifier: id) { [weak self] _ in
        self?.preferredContentSize.height ?? 0
      }
    ]

    sheet.selectedDetentIdentifier = id
  }

  private func updatePreferredContentSizeToFit() {
    view.layoutIfNeeded()

    let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
    let fitted = view.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )

    guard fitted.height > 0, preferredContentSize.height != fitted.height else { return }

    preferredContentSize = CGSize(width: preferredContentSize.width, height: fitted.height)
  }
}

// MARK: - Shared button helpers

extension VideoFeedBottomSheetViewController {
  func makeActionRowButton(
    title: String,
    systemImage: String,
    tint: UIColor? = nil,
    action: @escaping () -> Void
  ) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.title = title
    config.image = UIImage(systemName: systemImage)
    config.imagePadding = 10
    config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

    let button = UIButton(configuration: config)
    button.contentHorizontalAlignment = .leading
    button.tintColor = tint ?? .label
    button.addAction(UIAction { _ in action() }, for: .touchUpInside)

    return button
  }

  func makeSelectionRowButton(
    title: String,
    systemImage: String,
    action: @escaping () -> Void
  ) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.title = title
    config.image = UIImage(systemName: systemImage)
    config.imagePadding = 10
    config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

    let button = UIButton(configuration: config)
    button.contentHorizontalAlignment = .leading
    button.tintColor = .label
    button.addAction(UIAction { _ in action() }, for: .touchUpInside)

    return button
  }
}
