import UIKit
import Library
import ReactiveCocoa

protocol FindFriendsHeaderCellDelegate {
  func findFriendsHeaderCellDismissHeader()
  func findFriendsHeaderCellGoToFriends()
}

internal final class FindFriendsHeaderCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var findFriendsButton: BorderButton!
  @IBOutlet private weak var closeButton: UIButton!

  internal var delegate: FindFriendsHeaderCellDelegate?

  private let viewModel: FindFriendsHeaderCellViewModelType = FindFriendsHeaderCellViewModel()

  override func bindViewModel() {
    self.viewModel.outputs.notifyDelegateGoToFriends
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.findFriendsHeaderCellGoToFriends()
    }

    self.viewModel.outputs.notifyDelegateToDismissHeader
      .observeForUI()
      .observeNext { [weak self] in self?.delegate?.findFriendsHeaderCellDismissHeader()
    }
  }

  func configureWith(value source: FriendsSource) {
    self.viewModel.inputs.configureWith(source: source)
  }

  @IBAction func closeButtonTapped(sender: AnyObject) {
    self.viewModel.inputs.closeButtonTapped()
  }

  @IBAction func findFriendsButtonTapped(sender: AnyObject) {
    self.viewModel.inputs.findFriendsButtonTapped()
  }
}
