import Library
import Prelude
import UIKit

// swiftlint:disable line_length
internal final class DebugPushNotificationsViewController: UIViewController {

  @IBOutlet fileprivate weak var rootStackView: UIStackView!
  @IBOutlet fileprivate weak var scrollView: UIScrollView!
  @IBOutlet fileprivate var separatorViews: [UIView]!

    internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()

    let rowsStackViews = self.rootStackView.arrangedSubviews.flatMap { $0 as? UIStackView }
    let rowStackViews = rowsStackViews.flatMap { rows in
      rows.arrangedSubviews.flatMap { $0 as? UIStackView }
    }
    let buttonStackViews = rowStackViews.flatMap { $0.arrangedSubviews.last as? UIStackView }
    let titleLabels = self.rootStackView.arrangedSubviews.flatMap { $0 as? UILabel }
    let buttons = buttonStackViews
      .flatMap { stackView in stackView.arrangedSubviews.flatMap { $0 as? UIButton } }
    let inAppButtons = buttons.enumerated().filter { idx, _ in idx % 2 == 0 }.map(second)
    let delayedButtons = buttons.enumerated().filter { idx, _ in idx % 2 == 1 }.map(second)

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.scrollView
      |> UIScrollView.lens.delaysContentTouches .~ false

    _ = rowsStackViews
      ||> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = rowStackViews
      ||> UIStackView.lens.distribution .~ .equalSpacing
      ||> UIStackView.lens.alignment .~ .center

    _ = buttonStackViews
      ||> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = titleLabels
      ||> UILabel.lens.textColor .~ .ksr_text_navy_600
      ||> UILabel.lens.font .~ .ksr_title1(size: 22)

    _ = rowStackViews.flatMap { $0.arrangedSubviews.first as? UILabel }
      ||> UILabel.lens.textColor .~ .ksr_dark_grey_900
      ||> UILabel.lens.font .~ .ksr_body()

    _ = buttons
      ||> greenButtonStyle
      ||> UIButton.lens.contentEdgeInsets %~ {
        .init(top: $0.top/2, left: $0.left/2, bottom: $0.bottom/2, right: $0.right/2)
    }

    inAppButtons.enumerated().forEach { idx, button in
      _ = button
        |> UIButton.lens.tag .~ idx
        |> UIButton.lens.title(forState: .normal) .~ "In-app"
        |> UIButton.lens.targets .~ [(self, #selector(inAppButtonTapped(_:)), .touchUpInside)]
    }

    delayedButtons.enumerated().forEach { idx, button in
      _ = button
        |> UIButton.lens.tag .~ idx
        |> UIButton.lens.title(forState: .normal) .~ "Delayed"
        |> UIButton.lens.targets .~ [(self, #selector(delayedButtonTapped(_:)), .touchUpInside)]
    }

    _ = self.separatorViews
      ||> separatorStyle
  }

  @objc fileprivate func inAppButtonTapped(_ button: UIButton) {
    self.scheduleNotification(forIndex: button.tag, delay: false)
  }

  @objc fileprivate func delayedButtonTapped(_ button: UIButton) {
    self.scheduleNotification(forIndex: button.tag, delay: true)
  }

  fileprivate func scheduleNotification(forIndex index: Int, delay: Bool) {
    guard index >= 0 && index < allPushData.count else { return }

    let pushData = allPushData[index]

    let notification = UILocalNotification()
    notification.fireDate = Date(timeIntervalSinceNow: delay ? 5 : 0)
    notification.alertBody = (pushData["aps"] as? [String: AnyObject])?["alert"] as? String
    notification.userInfo = pushData
    UIApplication.shared.scheduleLocalNotification(notification)
  }
}

private let backingPushData: [String: Any] = [
  "aps": [
    "alert": "Blob McBlobby backed Double Fine Adventure."
  ],
  "activity": [
    "category": "backing",
    "id": 1,
    "project_id": 1929840910
  ]
]

private let updatePushData: [String: Any] = [
  "aps": [
    "alert": "Update #6 posted by Double Fine Adventure."
  ],
  "activity": [
    "category": "update",
    "id": 1,
    "project_id": 1929840910,
    "update_id": 190349
  ]
]

private let successPushData: [String: Any] = [
  "aps": [
    "alert": "Double Fine Adventure has been successfully funded!"
  ],
  "activity": [
    "category": "success",
    "id": 1,
    "project_id": 1929840910
  ]
]

private let failurePushData: [String: Any] = [
  "aps": [
    "alert": "Double Fine Adventure was not successfully funded."
  ],
  "activity": [
    "category": "failure",
    "id": 1,
    "project_id": 1929840910
  ]
]

private let cancellationPushData: [String: Any] = [
  "aps": [
    "alert": "Double Fine Adventure has been canceled."
  ],
  "activity": [
    "category": "cancellation",
    "id": 1,
    "project_id": 1929840910
  ]
]

private let followPushData: [String: Any] = [
  "aps": [
    "alert": "Blob McBlobby is following you on Kickstarter!"
  ],
  "activity": [
    "category": "follow",
    "id": 1
  ]
]

private let messagePushData: [String: Any] = [
  "aps": [
    "alert": "Chinati Foundation sent you a message about Robert Irwin Project."
  ],
  "message": [
    "message_thread_id": 17848074,
    "project_id": 820501933
  ]
]

private let surveyPushData: [String: Any] = [
  "aps": [
    "alert": "Response needed! Get your reward for backing Help Me Transform This Pile of Wood.",
  ],
  "survey": [
    "id": 15182605,
    "project_id": 820501933
  ]
]

private let reminderPushData: [String: Any] = [
  "aps": [
    "alert": "Reminder! This Pile of Wood is ending soon.",
  ],
  "project": [
    "photo": "https://ksr-ugc.imgix.net/assets/012/224/660/847bc4da31e6863e9351bee4e55b8005_original.jpg?w=160&h=90&fit=fill&bg=FBFAF8&v=1464773625&auto=format&q=92&s=fc738d87d861a96333e9f93bee680c27",
    "id": 820501933,
  ]
]

private let backingForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "New backer! Blob has pledged $50 to Help Me Transform This Pile Of Wood."
  ],
  "activity": [
    "category": "backing",
    "id": 1,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let messageForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "Blob McBlobby sent you a message about Help Me Transform This Pile Of Wood."
  ],
  "message": [
    "message_thread_id": 17848074,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let failureForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "Help Me Transform This Pile Of Wood was not successfully funded."
  ],
  "activity": [
    "category": "failure",
    "id": 1,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let successForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "Help Me Transform This Pile Of Wood has been successfully funded!"
  ],
  "activity": [
    "category": "success",
    "id": 1,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let cancellationForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "Help Me Transform This Pile Of Wood has been canceled."
  ],
  "activity": [
    "category": "cancellation",
    "id": 1,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let projectCommentForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "New comment! Blob has commented on Help Me Transform This Pile Of Wood."
  ],
  "activity": [
    "category": "comment-project",
    "id": 1,
    "project_id": 820501933
  ],
  "for_creator": true
]

private let updateCommentForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "New comment! Blob has commented on update #11."
  ],
  "activity": [
    "category": "comment-post",
    "id": 1,
    "project_id": 820501933,
    "update_id": 1731094
  ],
  "for_creator": true
]

private let postLikeForCreatorPushData: [String: Any] = [
  "aps": [
    "alert": "Blob liked your update: Important message from Tim..."
  ],
  "post": [
    "id": 175622,
    "project_id": 1929840910
  ],
  "for_creator": true
]

private let allPushData: [[String: Any]] = [
  backingPushData,
  updatePushData,
  successPushData,
  failurePushData,
  cancellationPushData,
  followPushData,
  messagePushData,
  surveyPushData,
  reminderPushData,
  backingForCreatorPushData,
  messageForCreatorPushData,
  failureForCreatorPushData,
  successForCreatorPushData,
  cancellationForCreatorPushData,
  projectCommentForCreatorPushData,
  updateCommentForCreatorPushData,
  postLikeForCreatorPushData,
]
