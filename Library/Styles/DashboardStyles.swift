import Prelude
import Prelude_UIKit
import UIKit

public let dashboardActivityButtonStyle = UIButton.lens.titleText(forState: .Normal)
  .~ Strings.dashboard_buttons_activity()

public let dashboardBackersLabelStyle = UILabel.lens.text .~ Strings.dashboard_tout_backers()
  <> UILabel.lens.textColor .~ .ksr_white
  <> UILabel.lens.font .~ .ksr_subhead

public let lastUpdatePublishedAtLabelStyle = UILabel.lens.font .~ .ksr_subhead
  <> UILabel.lens.textColor .~ .ksr_darkGrayText

public let dashboardMessagesButtonStyle = UIButton.lens.titleText(forState: .Normal)
  .~ Strings.dashboard_buttons_messages()

public let dashboardPledgedLabelStyle = UILabel.lens.text .~ Strings.dashboard_tout_pledged()
  <> UILabel.lens.textColor .~ .ksr_white
  <> UILabel.lens.font .~ .ksr_subhead

public let postUpdateButtonStyle = positiveButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) .~ Strings.dashboard_buttons_activity()

public let dashboardRemainingLabelStyle = UILabel.lens.text .~ Strings.dashboard_tout_remaining()
  <> UILabel.lens.textColor .~ .ksr_white
  <> UILabel.lens.font .~ .ksr_subhead

public let dashboardShareButtonStyle = neutralButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) .~ Strings.dashboard_buttons_share()
