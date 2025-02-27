import Combine
import Foundation
import SwiftUI
import UIKit

open class PagedContainerViewController<Page: TabBarPage>: UIViewController {
  private weak var activeController: UIViewController? = nil
  private var subscriptions = Set<AnyCancellable>()
  private let viewModel = PagedContainerViewModel<Page>()

  private lazy var toggle = UIHostingController(
    rootView: PagedTabBar(viewModel: self.viewModel)
  )

  private var tabBarPages: AnyPublisher<[Page], Never> {
    self.viewModel.$pages.map { $0.map { pair in
      let (page, _) = pair
      return page
    } }.eraseToAnyPublisher()
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white
    addChild(self.toggle)
    self.view.addSubview(self.toggle.view)
    self.toggle.view.translatesAutoresizingMaskIntoConstraints = false
    self.toggle.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    self.toggle.view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true

    // Prevent tab bar text from being set based on user preferences, since the UI isn't designed
    // to handle larger font sizes.
    self.toggle.view.maximumContentSizeCategory = .medium

    self.viewModel.$displayPage.receive(on: RunLoop.main)
      .compactMap { $0 }
      .sink { [weak self] _, controller in
        self?.showChildController(controller)
      }.store(in: &self.subscriptions)
  }

  /*
   The custom appearanceTransition code in this UIViewController was implemented
   so that the child view controllers will receive viewWillAppear with animated = true
   when a tab is selected.

   I initially implemented this because ActivitiesViewController filters unanimated
   calls to viewWillAppear; this behavior is relied on by our screenshot tests.

   While we should refactor the ActivitiesViewController, it also makes sense that transitions
   between pages in this container view controller will (eventually) be animated, even if
   I didn't animate them in this stub.
   */
  open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
    return false
  }

  open override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.viewWillAppear()

    if let activeController = self.activeController {
      activeController.beginAppearanceTransition(true, animated: animated)
    }
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if let activeController = self.activeController {
      activeController.endAppearanceTransition()
    }
  }

  override open func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if let activeController = self.activeController {
      activeController.beginAppearanceTransition(false, animated: animated)
    }
  }

  open override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    if let activeController = self.activeController {
      activeController.endAppearanceTransition()
    }
  }

  public func setPagedViewControllers(_ controllers: [(Page, UIViewController)]) {
    self.viewModel.configure(with: controllers)
    self.renderTabBar()
  }

  private func showChildController(_ controller: UIViewController) {
    if let activeController = self.activeController {
      self.stopDisplayingChildViewController(activeController)
    }

    self.displayChildViewController(
      controller,
      withConstraints: [
        self.toggle.view.bottomAnchor.constraint(equalTo: controller.view.topAnchor),
        self.view.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: controller.view.leftAnchor),
        self.view.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: controller.view.rightAnchor),
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
      ]
    )

    self.activeController = controller
  }

  private func renderTabBar() {
    self.toggle.rootView = PagedTabBar(viewModel: self.viewModel)
  }
}
