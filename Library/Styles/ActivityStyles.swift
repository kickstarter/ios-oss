import Prelude
import Prelude_UIKit
import UIKit

public let activitySurveyLabelStyle =
  UILabel.lens.font .~ .ksr_body()
    <> UILabel.lens.textAlignment .~ .Center

public let activityRespondNowButtonStyle = blackButtonStyle
  <> UIButton.lens.titleText(forState: .Normal) %~ { _ in
    Strings.discovery_survey_button_respond_now()
}

public let activitySurveyTableViewCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.backgroundColor .~ .ksr_orange_400
    <> UITableViewCell.lens.contentView.layoutMargins .~ .init(topBottom: 32.0, leftRight: 16.0)
