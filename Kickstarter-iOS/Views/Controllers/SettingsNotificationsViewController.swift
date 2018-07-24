import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNotificationsViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: UITableView!

  private let viewModel: SettingsNotificationsViewModelType = SettingsNotificationsViewModel()
  private let dataSource: SettingsNotificationsDataSource = SettingsNotificationsDataSource()

  internal static func instantiate() -> SettingsNotificationsViewController {
    return Storyboard.SettingsNotifications.instantiate(SettingsNotificationsViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = dataSource
    tableView.delegate = self

    tableView.register(nib: .SettingsNotificationCell)
    tableView.registerHeaderFooter(nib: .SettingsHeaderView)
    
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> UIViewController.lens.title %~ { _ in Strings.profile_settings_navbar_title_notifications() }

    _ = self.tableView
      |> UITableView.lens.backgroundColor .~ .ksr_grey_200
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToManageProjectNotifications
      .observeForControllerAction()
      .observeValues { [weak self] _ in self?.goToManageProjectNotifications() }

    self.viewModel.outputs.unableToSaveError
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.present(UIAlertController.genericError(message), animated: true, completion: nil)
    }

    self.viewModel.outputs.updateCurrentUser
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)

        self?.dataSource.load(user: user)
    }

    self.viewModel.outputs.goToFindFriends
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToFindFriends()
    }

    self.viewModel.outputs.goToEmailFrequency
      .observeForControllerAction()
      .observeValues { [weak self] user in
        self?.goToEmailFrequency(user: user)
    }

//    self.viewModel.outputs.reloadData
//    .observeForUI()
//    .observeValues { [weak self] isCreator in
//        self?.dataSource.configure(creatorNotificationsHidden: !isCreator)
//    }

//    self.viewModel.outputs.emailFrequencyButtonEnabled
//      .observeForUI()
//      .observeValues { [weak self] enabled in
//
//        _ = self?.emailFrequencyLabel
//            ?|> UILabel.lens.textColor .~ (enabled ? .ksr_text_dark_grey_500 : .ksr_text_dark_grey_400)
//
//        _ = self?.emailFrequencyArrow
//            ?|> UIImageView.lens.alpha .~ (enabled ? 1.0 : 0.5)
//    }

//    self.creatorNotificationsStackView.rac.hidden = self.viewModel.outputs.creatorNotificationsHidden
//    self.emailCreatorTipsButton.rac.selected = self.viewModel.outputs.emailCreatorTipsSelected
//    self.emailFrequencyButton.rac.enabled = self.viewModel.outputs.emailFrequencyButtonEnabled
//    self.emailNewCommentsButton.rac.selected = self.viewModel.outputs.emailNewCommentsSelected
//    self.emailNewLikesButton.rac.selected = self.viewModel.outputs.emailNewLikesSelected
//    self.emailNewPledgeButton.rac.selected = self.viewModel.outputs.emailNewPledgesSelected
//    self.emailProjectUpdatesButton.rac.selected = self.viewModel.outputs.emailProjectUpdatesSelected
//    self.followerButton.rac.selected = self.viewModel.outputs.emailNewFollowersSelected
//    self.friendActivityButton.rac.selected = self.viewModel.outputs.emailFriendsActivitySelected
//    self.manageProjectNotificationsButton.rac.accessibilityHint =
//    self.viewModel.outputs.manageProjectNotificationsButtonAccessibilityHint
//    self.mobileFollowerButton.rac.selected = self.viewModel.outputs.mobileNewFollowersSelected
//    self.mobileFriendActivityButton.rac.selected = self.viewModel.outputs.mobileFriendsActivitySelected
//    self.mobileMessagesButton.rac.selected = self.viewModel.outputs.mobileMessagesSelected
//    self.mobileNewPledgeButton.rac.selected = self.viewModel.outputs.mobileNewPledgesSelected
//    self.mobileNewCommentsButton.rac.selected = self.viewModel.outputs.mobileNewCommentsSelected
//    self.mobileNewLikesButton.rac.selected = self.viewModel.outputs.mobileNewLikesSelected
//    self.mobileUpdatesButton.rac.selected = self.viewModel.outputs.mobileProjectUpdatesSelected
//    self.messagesButton.rac.selected = self.viewModel.outputs.emailMessagesSelected
//    self.projectNotificationsCountView.label.rac.text = self.viewModel.outputs.projectNotificationsCount
  }

  fileprivate func goToEmailFrequency(user: User) {
    let vc = CreatorDigestSettingsViewController.configureWith(user: user)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToFindFriends() {
    let vc = FindFriendsViewController.configuredWith(source: .settings)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  fileprivate func goToManageProjectNotifications() {
    let vc = ProjectNotificationsViewController.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }
}

extension SettingsNotificationsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return SettingsNotificationSectionType.sectionHeaderHeight
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.1 // Required to remove the footer in UITableViewStyleGrouped
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Nib.SettingsHeaderView.rawValue) as? SettingsHeaderView
    let isCreator = AppEnvironment.current.currentUser?.isCreator ?? false
    guard let sectionType = dataSource.sectionType(section: section,
                                                   isCreator: isCreator) else {
      return nil
    }

    headerView?.configure(title: sectionType.sectionTitle)

    return headerView
  }

  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    guard let cellType = self.dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return false
    }

    return self.viewModel.shouldSelectRow(for: cellType)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    guard let cellType = dataSource.cellTypeForIndexPath(indexPath: indexPath) else {
      return
    }

    self.viewModel.inputs.didSelectRow(cellType: cellType)
  }
}
