import Foundation
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import UIKit
import XCTest

final class CommentComposerViewTests: TestCase {
  override func setUp() {
    super.setUp()

    AppEnvironment.pushEnvironment(mainBundle: Bundle.framework)
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    AppEnvironment.popEnvironment()
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testComposerView_User_CanPostComment_True() {
    let devices = [Device.phone4_7inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let composer = composerView(
          avatarURL: nil,
          canPostComment: true,
          composerViewHidden: false,
          textEntered: false
        )

        let vc = accessoryViewInViewController(
          composer,
          language: language,
          device: device
        )

        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testComposerView_User_CanPostComment_False() {
    let devices = [Device.phone4_7inch, Device.pad]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let composer = composerView(
          avatarURL: nil,
          canPostComment: false,
          composerViewHidden: false,
          textEntered: false
        )

        let vc = accessoryViewInViewController(
          composer,
          language: language,
          device: device
        )

        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testComposerView_WhenTextEntered_PostButtonDisplayed() {
    let devices = [Device.phone4_7inch, Device.pad]

    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(language: language) {
        let composer = composerView(
          avatarURL: nil,
          canPostComment: true,
          composerViewHidden: false,
          textEntered: true
        )

        let vc = accessoryViewInViewController(
          composer,
          language: language,
          device: device
        )

        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testComposerView_User_IsNotLoggedIn() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: nil, language: language) {
        let composer = composerView(
          avatarURL: nil,
          canPostComment: false,
          composerViewHidden: AppEnvironment.current.currentUser == nil,
          textEntered: false
        )

        let vc = accessoryViewInViewController(
          composer,
          language: language,
          device: device
        )

        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testComposerView_User_IsLoggedIn() {
    let devices = [Device.phone4_7inch, Device.phone5_8inch]
    combos(Language.allLanguages, devices).forEach { language, device in
      withEnvironment(currentUser: .template, language: language) {
        let composer = composerView(
          avatarURL: nil,
          canPostComment: true,
          composerViewHidden: AppEnvironment.current.currentUser == nil,
          textEntered: false
        )

        let vc = accessoryViewInViewController(
          composer,
          language: language,
          device: device
        )

        FBSnapshotVerifyView(
          vc.view,
          identifier: "CommentComposerView - lang_\(language)_device_\(device)"
        )
      }
    }
  }
}

private func composerView(avatarURL: URL?,
                          canPostComment: Bool,
                          composerViewHidden: Bool,
                          textEntered: Bool) -> CommentComposerView {
  let composer = CommentComposerView(frame: .zero)
    |> \.translatesAutoresizingMaskIntoConstraints .~ false

  composer.configure(with: (avatarURL, canPostComment, composerViewHidden, false))

  if textEntered {
    let textView = UITextView(frame: .zero)
    textView.text = "Sample"

    composer.textViewDidChange(textView)
  }

  return composer
}

private func accessoryViewInViewController(
  _ composer: CommentComposerView,
  language _: Language,
  device: Device
) -> UIViewController {
  let controller = UIViewController()
  let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
  _ = controller.view |> \.backgroundColor .~ .ksr_white
  controller.view.addSubview(composer)

  NSLayoutConstraint.activate([
    composer.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
    composer.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
    composer.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
  ])

  return parent
}
