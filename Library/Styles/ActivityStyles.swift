import Prelude
import Prelude_UIKit
import UIKit

public let activitySurveyLabelStyle =
  UILabel.lens.font .~ .ksr_body()
    <> UILabel.lens.textAlignment .~ .Center

public let activityRespondNowButtonStyle = blackButtonStyle
  <> UIButton.lens.title(forState: .Normal) %~ { _ in
    Strings.discovery_survey_button_respond_now()
}

public let activitySurveyTableViewCellStyle =
  baseTableViewCellStyle()
    <> UITableViewCell.lens.backgroundColor .~ .ksr_orange_400
    <> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
      cell.traitCollection.isRegularRegular
        ? .init(topBottom: Styles.grid(6), leftRight: Styles.grid(20))
        : .init(all: Styles.grid(4))
}
