import Prelude
import Library

internal final class CreatePasswordFooterView: UITableViewHeaderFooterView, NibLoading {

  @IBOutlet private weak var descriptionLabel: UILabel!

  func configure(with email: String?) {
    guard let email = email else {
      fatalError("Could not fetch user's email.")
    }

    _ = self.descriptionLabel
      |> \.text .~ Strings.Youre_connected_via_Facebook_email_Create_a_password_for_this_account(email: email)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.backgroundColor .~ .ksr_grey_200

    _ = self.descriptionLabel
      |> settingsDescriptionLabelStyle
      |> \.textColor .~ .ksr_text_dark_grey_500
  }
}
