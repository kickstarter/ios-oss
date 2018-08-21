import Library
import KsApi
import Prelude
import MessageUI

final class HelpViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let dataSource = HelpDataSource()
  fileprivate let helpViewModel: HelpViewModelType = HelpViewModel()

  internal static func instantiate() -> HelpViewController {
    return Storyboard.Settings.instantiate(HelpViewController.self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.helpViewModel.inputs.configureWith(helpContext: .settings)
    self.helpViewModel.inputs.canSendEmail(MFMailComposeViewController.canSendMail())

    tableView.dataSource = dataSource
    tableView.delegate = self
    tableView.register(nib: .SettingsTableViewCell)
    tableView.registerHeaderFooter(nib: .SettingsHeaderView)

    dataSource.configureRows()

    tableView.reloadData()
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_grey_200
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_about_title() }

    _ = tableView |> UITableView.lens.backgroundColor .~ .ksr_grey_200
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.helpViewModel.outputs.showMailCompose
      .observeForControllerAction()
      .observeValues { [weak self] in
        let controller = MFMailComposeViewController.support()
        controller.mailComposeDelegate = self
        self?.present(controller, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showNoEmailError
      .observeForControllerAction()
      .observeValues { [weak self] alert in
        self?.present(alert, animated: true, completion: nil)
    }

    self.helpViewModel.outputs.showWebHelp
      .observeForControllerAction()
      .observeValues { [weak self] helpType in
        self?.goToHelpType(helpType)
    }
  }

  fileprivate func goToHelpType(_ helpType: HelpType) {
    let vc = HelpWebViewController.configuredWith(helpType: helpType)
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension HelpViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return HelpSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove the footer in UITableViewStyleGrouped
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let helpType = self.dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }

    self.helpViewModel.inputs.helpTypeButtonTapped(helpType)
  }
}

extension HelpViewController: MFMailComposeViewControllerDelegate {
  internal func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
    self.helpViewModel.inputs.mailComposeCompletion(result: result)

    controller.dismiss(animated: true, completion: nil)
  }
}
