import KsApi
import Library
import Prelude
import Prelude_UIKit
import ReactiveSwift
import UIKit

public protocol SettingsRequestDataCellDelegate: class {
  func notifyDelegatePresentRequestDataPrompt()
}

internal final class SettingsPrivacyRequestDataCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: SettingsRequestDataCellViewModelType = SettingsRequestDataCellViewModel()
  internal weak var delegate: SettingsRequestDataCellDelegate?


  @IBOutlet fileprivate weak var requestDataLabel: UILabel!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate  var separatorViews: [UIView]!
  @IBOutlet fileprivate weak var requestDataButton: UIButton!

  internal func configureWith(value user: User) {

  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()

    _ = separatorViews
      ||> separatorStyle

    _ = self.requestDataLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.Request_my_Personal_Data() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.requestExportData
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.notifyDelegatePresentRequestDataPrompt()
    }
  }

  @IBAction func requestDataButtonTapped(_ sender: Any) {
    self.viewModel.inputs.exportDataTapped()
  }
}
