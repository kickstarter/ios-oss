import KsApi
import Library
import UIKit

private enum Constants {
  static let imageAspectRatio = CGFloat(9.0 / 16.0)
  static let cornerRadius = 12.0
  static let projectImageViewHeight = 198.0
  static let projectStatusStackViewSpacing = 8.0
  static let daysLeftImageViewHeight = 16.0
  static let daysLeftImageViewWidth = 16.0
  static let daysLeftLabelLeadingSpacing = 8.0
  static let progressBarHeight = 9.0
  static let viewSpacing = Styles.grid(3)
}

final class ProjectCardView: UIView {
  // MARK: - Properties

  private lazy var projectImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var projectTitleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var projectStatusStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var projectStatusLabel = { UILabel(frame: .zero) }()
  private lazy var projectStatusImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var progressBarContainerView = { UIView(frame: .zero) }()
  private lazy var progressBarView = { UIView(frame: .zero) }()

  private let viewModel: ProjectCardViewModelType = ProjectCardViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
    self.setupConstraints()
    self.bindStyles()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()
  }

  // MARK: - Configuration

  private func configureViews() {
    self.addSubview(self.projectImageView)
    self.addSubview(self.projectTitleLabel)
    self.addSubview(self.projectStatusStackView)
    self.addSubview(self.progressBarContainerView)

    self.projectStatusStackView.addArrangedSubviews(
      self.projectStatusImageView,
      self.projectStatusLabel
    )

    self.progressBarContainerView.addSubview(self.progressBarView)

    self.projectTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    self.projectStatusStackView.setContentCompressionResistancePriority(.required, for: .vertical)
    self.projectStatusLabel.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      // projectImageView
      self.projectImageView.topAnchor.constraint(equalTo: self.topAnchor),
      self.projectImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
      self.projectImageView.heightAnchor.constraint(
        equalTo: self.widthAnchor,
        multiplier: Constants.imageAspectRatio
      ),

      // projectTitleLabel
      self.projectTitleLabel.topAnchor.constraint(
        equalTo: self.projectImageView.bottomAnchor,
        constant: Constants.viewSpacing
      ),
      self.projectTitleLabel.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: Constants.viewSpacing
      ),
      self.projectTitleLabel.trailingAnchor.constraint(
        equalTo: self.trailingAnchor,
        constant: -Constants.viewSpacing
      ),

      // projectStatusStackView
      self.projectStatusStackView.topAnchor.constraint(
        equalTo: self.projectTitleLabel.bottomAnchor,
        constant: Styles.grid(2)
      ),
      self.projectStatusStackView.leadingAnchor.constraint(
        equalTo: self.leadingAnchor,
        constant: Constants.viewSpacing
      ),

      self.projectStatusStackView.bottomAnchor.constraint(
        equalTo: self.progressBarContainerView.topAnchor,
        constant: -Constants.viewSpacing
      ),

      // projectStatusImageView
      self.projectStatusImageView.heightAnchor.constraint(equalToConstant: Constants.daysLeftImageViewHeight),
      self.projectStatusImageView.widthAnchor.constraint(equalToConstant: Constants.daysLeftImageViewWidth),

      // progressBarContainerView
      self.progressBarContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.progressBarContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.progressBarContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.progressBarContainerView.heightAnchor.constraint(equalToConstant: Constants.progressBarHeight),

      // progressBarView
      self.progressBarView.topAnchor.constraint(equalTo: self.progressBarContainerView.topAnchor),
      self.progressBarView.leadingAnchor.constraint(equalTo: self.progressBarContainerView.leadingAnchor),
      self.progressBarView.trailingAnchor.constraint(equalTo: self.progressBarContainerView.trailingAnchor),
      self.progressBarView.bottomAnchor.constraint(equalTo: self.progressBarContainerView.bottomAnchor)
    ])
  }

  internal func configureWith(value: any SimilarProject) {
    self.viewModel.inputs.configureWith(project: value)

    self.layoutIfNeeded()
  }

  internal override func bindStyles() {
    super.bindStyles()

    applyBaseStyle(self)
    applyProjectImageViewStyle(self.projectImageView)
    applyProjectTitleLabelStyle(self.projectTitleLabel)
    applyProjectStatusStackViewStyle(self.projectStatusStackView)
    applyProjectStatusImageViewStyle(self.projectStatusImageView)
    applyProjectStatusLabelStyle(self.projectStatusLabel)
    applyProgressViewStyle(self.progressBarView)
    applyProgressBackgroundViewStyle(self.progressBarContainerView)

    self.setNeedsLayout()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.projectImageSource
      .compactMap { $0?.url }
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.projectImageView.af.cancelImageRequest()
        self?.projectImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.projectImageView.ksr_setImageWithURL(url)
      }

    self.viewModel.outputs.projectTitle
      .observeForUI()
      .observeValues { [weak self] title in
        self?.projectTitleLabel.text = title
      }

    self.viewModel.outputs.projectStatus
      .observeForUI()
      .observeValues { [weak self] text in
        self?.projectStatusLabel.text = text
      }

    self.viewModel.outputs.projectStatusImage
      .observeForUI()
      .observeValues { [weak self] image in
        guard let image = image else { return }

        self?.projectStatusImageView.image = image
      }

    self.viewModel.outputs.progressBarColor
      .observeForUI()
      .observeValues { [weak self] color in
        self?.progressBarView.backgroundColor = color
      }

    self.viewModel.outputs.prelaunchProject
      .observeForUI()
      .observeValues { [weak self] isPrelaunchProject in
        self?.progressBarContainerView.isHidden = isPrelaunchProject
      }

    self.viewModel.outputs.progress
      .observeForUI()
      .observeValues { [weak self] progress in
        let anchorX = progress == 0 ? 0 : 0.5 / progress
        self?.progressBarView.layer.anchorPoint = CGPoint(x: CGFloat(max(anchorX, 0.5)), y: 0.5)
        self?.progressBarView.transform = CGAffineTransform(scaleX: CGFloat(min(progress, 1.0)), y: 1.0)
      }
  }
}

private func applyBaseStyle(_ view: UIView) {
  view.backgroundColor = .ksr_white
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.layer.cornerRadius = Constants.cornerRadius
  view.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProjectStatusStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.alignment = .center
  stackView.spacing = Constants.projectStatusStackViewSpacing
  stackView.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProjectImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .scaleAspectFit
  imageView.backgroundColor = .ksr_support_300
  imageView.clipsToBounds = true
  imageView.accessibilityIgnoresInvertColors = true
  imageView.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProjectTitleLabelStyle(_ label: UILabel) {
  label.font = .ksr_title2()
  label.textColor = .ksr_black
  label.numberOfLines = 2
  label.lineBreakMode = .byTruncatingTail
  label.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProjectStatusImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .scaleAspectFit
  imageView.clipsToBounds = true
  imageView.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProjectStatusLabelStyle(_ label: UILabel) {
  label.font = UIFont.ksr_bodyMD()
  label.textColor = .ksr_support_400
  label.numberOfLines = 0
  label.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProgressViewStyle(_ view: UIView) {
  view.translatesAutoresizingMaskIntoConstraints = false
}

private func applyProgressBackgroundViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_support_100
  view.translatesAutoresizingMaskIntoConstraints = false
}
