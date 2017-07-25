// swiftlint:disable force_cast
@testable import Library
@testable import ReactiveExtensions_TestHelpers
import MessageUI
import Prelude
import ReactiveSwift
import Result
import UIKit
import XCTest

internal final class HelpViewModelTests: TestCase {
  fileprivate let vm: HelpViewModelType = HelpViewModel()

  fileprivate let showNoEmailError = TestObserver<UIAlertController, NoError>()
  fileprivate let showHelpSheet = TestObserver<[HelpType], NoError>()
  fileprivate let showMailCompose = TestObserver<(), NoError>()
  fileprivate let showWebHelp = TestObserver<HelpType, NoError>()

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
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.helpTypeButtonTapped(.cookie)

    self.showWebHelp.assertValues([HelpType.cookie])
    XCTAssertEqual(["Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual(["Settings"], self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual(["Cookie Policy"], self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.helpTypeButtonTapped(.faq)

    self.showWebHelp.assertValues([HelpType.cookie, HelpType.faq])
    XCTAssertEqual(["Selected Help Option", "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual(["Settings", "Settings"], self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual(["Cookie Policy", "FAQ"], self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.helpTypeButtonTapped(.howItWorks)

    self.showWebHelp.assertValues([HelpType.cookie, HelpType.faq, HelpType.howItWorks])
    XCTAssertEqual(["Selected Help Option", "Selected Help Option", "Selected Help Option"],
                   self.trackingClient.events)
    XCTAssertEqual(["Settings", "Settings", "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual(["Cookie Policy", "FAQ", "How It Works"],
                   self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.helpTypeButtonTapped(.privacy)

    self.showWebHelp.assertValues([HelpType.cookie, HelpType.faq, HelpType.howItWorks, HelpType.privacy])
    XCTAssertEqual(["Selected Help Option", "Selected Help Option", "Selected Help Option",
      "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual(["Settings", "Settings", "Settings", "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual(["Cookie Policy", "FAQ", "How It Works", "Privacy Policy"],
                   self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.helpTypeButtonTapped(.terms)

    self.showWebHelp.assertValues([HelpType.cookie, .faq, .howItWorks, .privacy,
      .terms])
    self.showMailCompose.assertValueCount(0)
    self.showNoEmailError.assertValueCount(0)
    XCTAssertEqual(["Selected Help Option", "Selected Help Option", "Selected Help Option",
      "Selected Help Option", "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual(["Settings", "Settings", "Settings", "Settings", "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual(["Cookie Policy", "FAQ", "How It Works", "Privacy Policy", "Terms"],
                   self.trackingClient.properties.map { $0["type"] as! String? })
  }

  func testFlow_Contact() {
    self.vm.inputs.configureWith(helpContext: HelpContext.settings)
    self.vm.inputs.canSendEmail(true)

    self.showMailCompose.assertValueCount(0)
    self.showNoEmailError.assertValueCount(0)
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.helpTypeButtonTapped(.contact)

    self.showMailCompose.assertValueCount(1)
    XCTAssertEqual(["Contact Email Open", "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual([nil, "Settings"], self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual([nil, "Contact"], self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.mailComposeCompletion(result: .sent)

    XCTAssertEqual(["Contact Email Open", "Selected Help Option", "Sent Contact Email", "Contact Email Sent"],
                   self.trackingClient.events)
    XCTAssertEqual([nil, "Settings", "Settings", nil],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual([nil, "Contact", nil, nil], self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.helpTypeButtonTapped(HelpType.contact)

    self.showMailCompose.assertValueCount(2)
    XCTAssertEqual(["Contact Email Open", "Selected Help Option", "Sent Contact Email",
      "Contact Email Sent", "Contact Email Open", "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual([nil, "Settings", "Settings", nil, nil, "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual([nil, "Contact", nil, nil, nil, "Contact"],
                   self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.mailComposeCompletion(result: .cancelled)

    self.showNoEmailError.assertValueCount(0)
    XCTAssertEqual(["Contact Email Open", "Selected Help Option", "Sent Contact Email",
      "Contact Email Sent", "Contact Email Open", "Selected Help Option", "Canceled Contact Email"],
                   self.trackingClient.events)
    XCTAssertEqual([nil, "Settings", "Settings", nil, nil, "Settings", "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual([nil, "Contact", nil, nil, nil, "Contact", nil],
                   self.trackingClient.properties.map { $0["type"] as! String? })

    self.vm.inputs.canSendEmail(false)
    self.vm.inputs.helpTypeButtonTapped(HelpType.contact)

    self.showNoEmailError.assertValueCount(1)
    self.showWebHelp.assertValueCount(0)
    XCTAssertEqual(["Contact Email Open", "Selected Help Option", "Sent Contact Email",
      "Contact Email Sent", "Contact Email Open", "Selected Help Option", "Canceled Contact Email",
      "Selected Help Option"], self.trackingClient.events)
    XCTAssertEqual([nil, "Settings", "Settings", nil, nil, "Settings", "Settings", "Settings"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
    XCTAssertEqual([nil, "Contact", nil, nil, nil, "Contact", nil, "Contact"],
                   self.trackingClient.properties.map { $0["type"] as! String? })
  }

  func testHelpSheet() {
    self.vm.inputs.configureWith(helpContext: HelpContext.loginTout)
    self.vm.inputs.canSendEmail(true)

    self.showHelpSheet.assertValueCount(0)

    self.vm.inputs.showHelpSheetButtonTapped()

    self.showHelpSheet.assertValues([[HelpType.howItWorks, .contact, .terms, .privacy, .cookie]])
    XCTAssertEqual(["Showed Help Menu"], self.trackingClient.events)
    XCTAssertEqual(["Login Tout"], self.trackingClient.properties.map { $0["context"] as! String? })

    self.vm.inputs.cancelHelpSheetButtonTapped()

    XCTAssertEqual(["Showed Help Menu", "Canceled Help Menu"], self.trackingClient.events)
    XCTAssertEqual(["Login Tout", "Login Tout"],
                   self.trackingClient.properties.map { $0["context"] as! String? })

    self.vm.inputs.configureWith(helpContext: .signup)
    self.vm.inputs.canSendEmail(true)

    self.vm.inputs.showHelpSheetButtonTapped()
    XCTAssertEqual(["Showed Help Menu", "Canceled Help Menu", "Showed Help Menu"], self.trackingClient.events)
    XCTAssertEqual(["Login Tout", "Login Tout", "Signup"],
                   self.trackingClient.properties.map { $0["context"] as! String? })
  }
}
