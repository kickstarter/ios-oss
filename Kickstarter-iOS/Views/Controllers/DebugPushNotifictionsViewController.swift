import Library
import Prelude
import UIKit

internal final class DebugPushNotificationsViewController: UIViewController {

  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private var separatorViews: [UIView]!

  // swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseControllerStyle()

    let rowsStackViews = self.rootStackView.arrangedSubviews.flatMap { $0 as? UIStackView }
    let rowStackViews = rowsStackViews.flatMap { rows in
      rows.arrangedSubviews.flatMap { $0 as? UIStackView }
    }
    let buttonStackViews = rowStackViews.flatMap { $0.arrangedSubviews.last as? UIStackView }
    let titleLabels = self.rootStackView.arrangedSubviews.flatMap { $0 as? UILabel }
    let buttons = buttonStackViews
      .flatMap { stackView in stackView.arrangedSubviews.flatMap { $0 as? UIButton } }
    let inAppButtons = buttons.enumerate().filter { idx, _ in idx % 2 == 0 }.map(second)
    let delayedButtons = buttons.enumerate().filter { idx, _ in idx % 2 == 1 }.map(second)

    self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.scrollView
      |> UIScrollView.lens.delaysContentTouches .~ false

    rowsStackViews
      ||> UIStackView.lens.spacing .~ Styles.grid(2)

    rowStackViews
      ||> UIStackView.lens.distribution .~ .EqualSpacing
      ||> UIStackView.lens.alignment .~ .Center

    buttonStackViews
      ||> UIStackView.lens.spacing .~ Styles.grid(1)

    titleLabels
      ||> UILabel.lens.textColor .~ .ksr_text_navy_600
      ||> UILabel.lens.font .~ .ksr_title1(size: 22)

    rowStackViews.flatMap { $0.arrangedSubviews.first as? UILabel }
      ||> UILabel.lens.textColor .~ .ksr_text_navy_900
      ||> UILabel.lens.font .~ .ksr_body()

    buttons
      ||> greenButtonStyle
      ||> UIButton.lens.contentEdgeInsets %~ {
        .init(top: $0.top/2, left: $0.left/2, bottom: $0.bottom/2, right: $0.right/2)
    }

    inAppButtons.enumerate().forEach { idx, button in
      button
        |> UIButton.lens.tag .~ idx
        |> UIButton.lens.title(forState: .Normal) .~ "In-app"
        |> UIButton.lens.targets .~ [(self, #selector(inAppButtonTapped(_:)), .TouchUpInside)]
    }

    delayedButtons.enumerate().forEach { idx, button in
      button
        |> UIButton.lens.tag .~ idx
        |> UIButton.lens.title(forState: .Normal) .~ "Delayed"
        |> UIButton.lens.targets .~ [(self, #selector(delayedButtonTapped(_:)), .TouchUpInside)]
    }

    self.separatorViews
      ||> separatorStyle
  }
  // swiftlint:enable function_body_length

  @objc private func inAppButtonTapped(button: UIButton) {
    self.scheduleNotification(forIndex: button.tag, delay: false)
  }

  @objc private func delayedButtonTapped(button: UIButton) {
    self.scheduleNotification(forIndex: button.tag, delay: true)
  }

  private func scheduleNotification(forIndex index: Int, delay: Bool) {
    guard index >= 0 && index < allPushData.count else { return }

    let pushData = allPushData[index]

    let notification = UILocalNotification()
    notification.fireDate = NSDate(timeIntervalSinceNow: delay ? 5 : 0)
    notification.alertBody = (pushData["aps"] as? [String:AnyObject])?["alert"] as? String
    notification.userInfo = pushData
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
  }
}

private let allPushData: [[String:AnyObject]] = [
  [
    "aps": [
      "alert": "Blob McBlobby backed Double Fine Adventure."
    ],
    "activity": [
      "category": "backing",
      "id": 1,
      "project_id": 1929840910
    ]
  ],

  [
    "aps": [
      "alert": "Update #6 posted by Double Fine Adventure."
    ],
    "activity": [
      "category": "comment-post",
      "id": 1,
      "project_id": 1929840910,
      "update_id": 190349
    ]
  ],

  [
    "aps": [
      "alert": "Double Fine Adventure has been successfully funded!"
    ],
    "activity": [
      "category": "success",
      "id": 1,
      "project_id": 1929840910
    ]
  ],

  [
    "aps": [
      "alert": "Double Fine Adventure was not successfully funded."
    ],
    "activity": [
      "category": "failure",
      "id": 1,
      "project_id": 1929840910
    ]
  ],


  [
    "aps": [
      "alert": "Double Fine Adventure has been canceled."
    ],
    "activity": [
      "category": "cancellation",
      "id": 1,
      "project_id": 1929840910
    ]
  ],


  [
    "aps": [
      "alert": "Blob McBlobby is following you on Kickstarter!"
    ],
    "activity": [
      "category": "follow",
      "id": 1
    ]
  ],

  [
    "aps": [
      "alert": "Blob McBlobby sent you a message about Blobs Around The Globe."
    ],
    "message": [
      "message_thread_id": 1,
      "project_id": 1
    ]
  ],

  [
    "aps": [
      "alert": "Response needed! Get your reward for backing Double Fine Adventure.",
    ],
    "survey": [
      "project_id": 1929840910
    ]
  ],

  [
    "aps": [
      "alert": "New backer! Blob has pledged $50 to Help Me Transform This Pile Of Wood."
    ],
    "activity": [
      "category": "backing",
      "id": 1,
      "project_id": 820501933
    ],
    "for_creator": true
  ],

  [
    "aps": [
      "alert": "Blob McBlobby sent you a message about Help Me Transform This Pile Of Wood."
    ],
    "message": [
      "message_thread_id": 1,
      "project_id": 820501933
    ],
    "for_creator": true
  ],

  [
    "aps": [
      "alert": "Help Me Transform This Pile Of Wood was not successfully funded."
    ],
    "activity": [
      "category": "failure",
      "id": 1,
      "project_id": 820501933
    ]
  ],

  [
    "aps": [
      "alert": "Help Me Transform This Pile Of Wood has been successfully funded!"
    ],
    "activity": [
      "category": "success",
      "id": 1,
      "project_id": 820501933
    ]
  ],

  [
    "aps": [
      "alert": "Help Me Transform This Pile Of Wood has been canceled."
    ],
    "activity": [
      "category": "cancellation",
      "id": 1,
      "project_id": 820501933
    ]
  ],

  [
    "aps": [
      "alert": "New comment! Blob has commented on Help Me Transform This Pile Of Wood."
    ],
    "activity": [
      "category": "comment-project",
      "id": 1,
      "project_id": 820501933
    ]
  ],

  [
    "aps": [
      "alert": "New comment! Blob has commented on update #10."
    ],
    "activity": [
      "category": "comment-post",
      "id": 1,
      "project_id": 820501933,
      "update_id": 1393331
    ]
  ],
]
