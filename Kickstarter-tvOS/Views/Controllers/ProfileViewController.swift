import UIKit
import ReactiveCocoa
import ReactiveExtensions
import AlamofireImage
import Library

final class ProfileViewController: UIViewController {
  @IBOutlet private weak var avatarImageView: UIImageView?
  @IBOutlet private weak var nameLabel: UILabel!

  let viewModel: ProfileViewModel

  init(viewModel: ProfileViewModel) {
    self.viewModel = viewModel
    super.init(nibName: ProfileViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func bindViewModel() {
    super.bindViewModel()

    viewModel.outputs.avatarURL.producer.ignoreNil()
      .observeForUI()
      .startWithNext { [weak self] url in
        self?.avatarImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.3))
    }

    nameLabel.rac.text = viewModel.outputs.name.signal.ignoreNil()
  }

  @IBAction func logoutPressed(sender: UIButton) {
    viewModel.inputs.logoutPressed()
  }
}
