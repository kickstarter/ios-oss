import Library
import Prelude
import UIKit

private enum Constants {
  static let rootStackViewSpacing: CGFloat = 0.0
  static let borderWidth: CGFloat = 1.0
  static let headerStackViewSpacing: CGFloat = Styles.grid(1)

  static let layoutMargins: UIEdgeInsets = .init(all: Styles.grid(2))

  static let projectImageWidthMultiplier: CGFloat = 0.25
  static let projectImageAspectRatio: CGFloat = 0.5
}

final class TrackingActivitiesCell: UITableViewCell, ValueCell {
  // MARK: - Properties

  private let viewModel: TrackingActivitiesCellViewModelType = TrackingActivitiesCellViewModel()
  public weak var delegate: RewardTrackingDetailsViewDelegate? {
    get { self.rewardTrackingDetailsView.delegate }
    set { self.rewardTrackingDetailsView.delegate = newValue }
  }

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rewardTrackingDetailsView: RewardTrackingDetailsView = {
    RewardTrackingDetailsView(style: .activity)
  }()

  private lazy var headerStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var projectNameLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var projectImageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var separatorView: UIView = { UIView(frame: .zero) }()

  // MARK: - Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.configureViews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  private func configureViews() {
    self.contentView.addSubview(self.rootStackView)

    self.headerStackView.addArrangedSubviews(
      self.projectNameLabel,
      self.projectImageView
    )

    self.rootStackView.addArrangedSubviews(
      self.headerStackView,
      self.separatorView,
      self.rewardTrackingDetailsView
    )
  }

  private func setupConstraints() {
    self.rootStackView.constrainViewToMargins(in: self.contentView)

    NSLayoutConstraint.activate([
      // Set the width of the project image view to 25% of the cell's content view width
      self.projectImageView.widthAnchor.constraint(
        equalTo: self.contentView.widthAnchor,
        multiplier: Constants.projectImageWidthMultiplier
      ),
      // Set the height of the project image view to be 50% of its own width (maintains a 2:1 aspect ratio)
      self.projectImageView.heightAnchor.constraint(
        equalTo: self.projectImageView.widthAnchor,
        multiplier: Constants.projectImageAspectRatio
      )
    ])

    self.projectImageView.setContentHuggingPriority(.required, for: .horizontal)
    self.projectImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

    self.separatorView.translatesAutoresizingMaskIntoConstraints = false
    self.separatorView.heightAnchor.constraint(equalToConstant: Constants.borderWidth).isActive = true
  }

  override func bindStyles() {
    super.bindStyles()

    _ = baseTableViewCellStyle()(self)

    applyContentViewStyle(self.contentView)
    applyRootStackViewStyle(self.rootStackView)
    applyHeaderStackViewStyle(self.headerStackView)
    applyProjectLabelStyle(self.projectNameLabel)
    applyProjectImageViewStyle(self.projectImageView)
    applySeperatorViewStyle(self.separatorView)

//    self.rewardTrackingDetailsView.setContentHuggingPriority(.required, for: .vertical)
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(event: { [weak projectImageView] _ in
        projectImageView?.af.cancelImageRequest()
        projectImageView?.image = nil
      })
      .observeValues { [weak projectImageView] url in
        projectImageView?.ksr_setImageWithURL(url)
      }
  }

  internal func configureWith(value data: TrackingActivitiesCellData) {
    self.rewardTrackingDetailsView.configure(with: data.trackingData)
    self.viewModel.inputs.configure(with: data.project)

    self.rewardTrackingDetailsView.setNeedsLayout()
    self.rewardTrackingDetailsView.layoutIfNeeded()
    self.contentView.setNeedsLayout()
    self.contentView.layoutIfNeeded()
  }
}

// MARK: - Styles

private func applyContentViewStyle(_ view: UIView) {
  view.layoutMargins = Constants.layoutMargins
}

private func applyRootStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .vertical
  stackView.spacing = Constants.rootStackViewSpacing
  stackView.layer.borderWidth = Constants.borderWidth
  stackView.layer.borderColor = UIColor.ksr_support_300.cgColor
}

private func applyHeaderStackViewStyle(_ stackView: UIStackView) {
  stackView.axis = .horizontal
  stackView.spacing = Constants.headerStackViewSpacing
  stackView.layoutMargins = Constants.layoutMargins
  stackView.isLayoutMarginsRelativeArrangement = true
}

private func applyProjectLabelStyle(_ label: UILabel) {
  label.font = .ksr_headingMD()
  label.textColor = .ksr_support_400
}

private func applyProjectImageViewStyle(_ imageView: UIImageView) {
  imageView.contentMode = .scaleAspectFit
  imageView.clipsToBounds = true
}

private func applySeperatorViewStyle(_ view: UIView) {
  view.backgroundColor = .ksr_support_200
}
