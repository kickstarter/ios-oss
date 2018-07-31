import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

public protocol SettingsRequestDataCellDelegate: class {
  func shouldPresentRequestDataPrompt()
  func shouldRequestData(with url: String)
}

internal final class SettingsPrivacyRequestDataCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = SettingsRequestDataCellViewModel()
  internal weak var delegate: SettingsRequestDataCellDelegate?

  @IBOutlet fileprivate weak var requestDataLabel: UILabel!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var requestDataButton: UIButton!
  @IBOutlet fileprivate weak var requestDataActivityIndicator: UIActivityIndicatorView!

  private var requestDataObserver: Any?

  public enum DataRequestType {
      case request
      case download
    }

  internal override func awakeFromNib() {
    self.requestDataButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)

    self.requestDataObserver = NotificationCenter.default.addObserver(
      forName: Notification.Name.ksr_dataRequested,
      object: nil, queue: nil) { [weak self] _ in self?.viewModel.inputs.startRequestDataTapped() }

    super.awakeFromNib()
  }

  deinit {
    self.requestDataObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  internal func configureWith(value: User) {
    self.viewModel.inputs.configureWith(user: value)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = separatorViews
      ||> separatorStyle

    _ = self.requestDataActivityIndicator
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _ = self.requestDataLabel
      |> settingsSectionLabelStyle
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.showRequestDataPrompt
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.shouldPresentRequestDataPrompt()
    }

    self.viewModel.outputs.goToSafari
      .observeForUI()
      .observeValues { [weak self] url in
        self?.delegate?.shouldRequestData(with: url)
    }

    self.requestDataButton.rac.enabled = self.viewModel.outputs.requestDataButtonEnabled
    self.requestDataActivityIndicator.rac.animating = self.viewModel.outputs.requestDataLoadingIndicator
    self.requestDataLabel.rac.text = self.viewModel.outputs.requestDataText
  }

  @objc fileprivate func exportButtonTapped() {
    self.viewModel.inputs.exportDataTapped()
  }
}
