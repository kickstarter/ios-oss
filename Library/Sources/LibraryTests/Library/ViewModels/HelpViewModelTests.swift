@testable import Library
import MessageUI
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import UIKit
import XCTest

internal final class HelpViewModelTests: TestCase {
  fileprivate let vm: HelpViewModelType = HelpViewModel()

  fileprivate let showNoEmailError = TestObserver<UIAlertController, Never>()
  fileprivate let showHelpSheet = TestObserver<[HelpType], Never>()
  fileprivate let showMailCompose = TestObserver<(), Never>()
  fileprivate let showWebHelp = TestObserver<HelpType, Never>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.showNoEmailError.observe(self.showNoEmailError.observer)
    self.vm.outputs.showHelpSheet.observe(self.showHelpSheet.observer)
    self.vm.outputs.showMailCompose.observe(self.showMailCompose.observer)
    self.vm.outputs.showWebHelp.observe(self.showWebHelp.observer)
  }

  func testHelpFlow() {
    self.vm.inputs.configureWith(helpContext: HelpContext.settings)
    self.vm.inputs.canSendEmail(true)

    self.showWebHelp.assertValueCount(0)

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.helpTypeButtonTapped(.cookie)

    self.showWebHelp.assertValues([HelpType.cookie])

    self.vm.inputs.helpTypeButtonTapped(.helpCenter)

    self.showWebHelp.assertValues([HelpType.cookie, HelpType.helpCenter])

    self.vm.inputs.helpTypeButtonTapped(.howItWorks)

    self.showWebHelp.assertValues([HelpType.cookie, HelpType.helpCenter, HelpType.howItWorks])

    self.vm.inputs.helpTypeButtonTapped(.privacy)

    self.showWebHelp.assertValues(
      [HelpType.cookie, HelpType.helpCenter, HelpType.howItWorks, HelpType.privacy]
    )

    self.vm.inputs.helpTypeButtonTapped(.terms)

    self.showWebHelp.assertValues([
      HelpType.cookie, .helpCenter, .howItWorks, .privacy,
      .terms
    ])
    self.showMailCompose.assertValueCount(0)
    self.showNoEmailError.assertValueCount(0)
  }

  func testFlow_Contact() {
    self.vm.inputs.configureWith(helpContext: HelpContext.settings)
    self.vm.inputs.canSendEmail(true)

    self.showMailCompose.assertValueCount(0)
    self.showNoEmailError.assertValueCount(0)

    XCTAssertEqual([], self.segmentTrackingClient.events)

    self.vm.inputs.helpTypeButtonTapped(.contact)

    self.showMailCompose.assertValueCount(1)

    self.vm.inputs.mailComposeCompletion(result: .sent)

    self.vm.inputs.helpTypeButtonTapped(HelpType.contact)

    self.showMailCompose.assertValueCount(2)

    self.vm.inputs.mailComposeCompletion(result: .cancelled)

    self.showNoEmailError.assertValueCount(0)

    self.vm.inputs.canSendEmail(false)
    self.vm.inputs.helpTypeButtonTapped(HelpType.contact)

    self.showNoEmailError.assertValueCount(1)
    self.showWebHelp.assertValueCount(0)
  }

  func testHelpSheet() {
    self.vm.inputs.configureWith(helpContext: HelpContext.loginTout)
    self.vm.inputs.canSendEmail(true)

    self.showHelpSheet.assertValueCount(0)

    self.vm.inputs.showHelpSheetButtonTapped()

    self.showHelpSheet.assertValues([[HelpType.howItWorks, .contact, .terms, .privacy, .cookie]])

    self.vm.inputs.configureWith(helpContext: .signup)
    self.vm.inputs.canSendEmail(true)

    self.vm.inputs.showHelpSheetButtonTapped()
  }
}
