//
//  ThanksViewControllerTests.swift
//  Library-iOSTests
//
//  Created by Isabel Barrera on 5/7/18.
//  Copyright © 2018 Kickstarter. All rights reserved.
//

import KsApi
import Library
import Prelude
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library

class ThanksViewControllerTests: TestCase {

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

    func testThanksViewController() {
      let discoveryEnvelope = DiscoveryEnvelope.template
      let rootCategories = RootCategoriesEnvelope(rootCategories: [Category.art])
      let mockService = MockService(fetchGraphCategoriesResponse: rootCategories,
                                    fetchDiscoveryResponse: discoveryEnvelope)

      combos(Language.allLanguages, [Device.phone4_7inch, Device.pad]).forEach { language, device in
        withEnvironment(apiService: mockService, language: language) {
          let project = Project.cosmicSurgery
          |> Project.lens.id .~ 3

          let controller = ThanksViewController.configuredWith(project: project)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.run()

          FBSnapshotVerifyView(parent.view, identifier: "lang_\(language)_device_\(device)")
        }
      }
    }
}
