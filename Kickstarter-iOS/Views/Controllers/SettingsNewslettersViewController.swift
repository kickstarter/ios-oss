import KsApi
import Library
import Prelude
import UIKit

internal final class SettingsNewslettersViewController: UIViewController {

  @IBOutlet fileprivate weak var artsAndCultureDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var artsAndCultureNewsLabel: UILabel!
  @IBOutlet fileprivate weak var artsAndCultureNewsSwitch: UISwitch!
  @IBOutlet fileprivate weak var happeningNowDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var happeningNowLabel: UILabel!
  @IBOutlet fileprivate weak var happeningNowSwitch: UISwitch!
  @IBOutlet fileprivate weak var projectsWeLoveDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var projectsWeLoveLabel: UILabel!
  @IBOutlet fileprivate weak var projectsWeLoveSwitch: UISwitch!
  @IBOutlet fileprivate weak var ksrLovesGamesDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var ksrLovesGamesLabel: UILabel!
  @IBOutlet fileprivate weak var ksrLovesGamesSwitch: UISwitch!
  @IBOutlet fileprivate weak var ksrNewsAndEventsDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var ksrNewsAndEventsLabel: UILabel!
  @IBOutlet fileprivate weak var ksrNewsAndEventsSwitch: UISwitch!
  @IBOutlet fileprivate weak var inventDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var inventLabel: UILabel!
  @IBOutlet fileprivate weak var inventSwitch: UISwitch!
  @IBOutlet fileprivate weak var subscribeDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var subscribeLabel: UILabel!
  @IBOutlet fileprivate weak var subscribeSwitch: UISwitch!
  @IBOutlet fileprivate var descriptionLabels: [UILabel]!
  @IBOutlet fileprivate var separatorViews: [UIView]!

  internal static func instantiate() -> SettingsNewslettersViewController {
    return Storyboard.SettingsNewsletters.instantiate(SettingsNewslettersViewController.self)
  }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

  override func bindStyles() {

    _ = self.descriptionLabels
      ||> settingsSectionLabelStyle
      ||> UILabel.lens.font .~ .ksr_body(size: 13)

    _ = self.separatorViews
      ||> separatorStyle

    _ = self.artsAndCultureNewsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_arts() }

    _ = self.artsAndCultureDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Stay_up_to_date_newsletter() }

    _ = self.happeningNowLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_happening() }

    _ = self.happeningNowDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Happening_newsletter() }

    _ = self.inventLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_invent() }

    _ = self.inventDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Stay_up_to_date_newsletter() }

    _ = self.ksrLovesGamesLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_rating_option_title_show_us_some_love() }

    _ = self.ksrLovesGamesDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Stay_up_to_date_newsletter() }

    _ = self.ksrNewsAndEventsLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_news_event() }

    _ = self.ksrNewsAndEventsDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.News_events() }

    _ = self.projectsWeLoveLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_weekly() }

    _ = self.projectsWeLoveDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Sign_up_newsletter() }

    _ = self.subscribeLabel
      |> settingsSectionLabelStyle
      |> UILabel.lens.text %~ { _ in Strings.profile_settings_newsletter_subscribe_all() }

    _ = self.subscribeDescriptionLabel
      |> UILabel.lens.text %~ { _ in Strings.Stay_up_to_date_newsletter() }
  }
}
