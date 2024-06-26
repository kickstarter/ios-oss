import Combine
import Foundation
import UIKit

open class PagedContainerViewController: UIViewController {
  private weak var activeController: UIViewController? = nil
  private var subscriptions = Set<AnyCancellable>()
  private let viewModel = PagedContainerViewModel()

  // TODO: Use the correct page control, per the designs.
  // This may exist already in SortPagerViewController, or we can write one in SwiftUI.
  private lazy var toggle = UISegmentedControl(
    frame: .zero,
    actions: []
  )

  open override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = .white
    self.view.addSubview(self.toggle)
    self.toggle.translatesAutoresizingMaskIntoConstraints = false
    self.toggle.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    self.toggle.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true

    self.viewModel.pageTitles
      .sink { [weak self] titles in
        self?.configureSegmentedControl(withTitles: titles)
      }.store(in: &self.subscriptions)

    self.viewModel.displayChildViewControllerAtIndex.receive(on: RunLoop.main)
      .sink { [weak self] controller, index in
        self?.showChildController(controller, atIndex: index)
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

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.viewWillAppear()

    if let activeController = self.activeController {
      activeController.beginAppearanceTransition(true, animated: animated)
    }
  }

  public override func viewDidAppear(_ animated: Bool) {
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

  public func setPagedViewControllers(_ controllers: [UIViewController]) {
    self.viewModel.configure(withChildren: controllers)
  }

  private func configureSegmentedControl(withTitles titles: [String]) {
    self.toggle.removeAllSegments()

    for (idx, title) in titles.enumerated() {
      let action = UIAction(
        title: title,
        handler: { [weak self] _ in self?.viewModel.didSelectPage(atIndex: idx) }
      )
      self.toggle.insertSegment(action: action, at: idx, animated: false)
    }
  }

  private func showChildController(_ controller: UIViewController, atIndex index: Int) {
    if self.toggle.selectedSegmentIndex == UISegmentedControl.noSegment {
      self.toggle.selectedSegmentIndex = index
    }

    if let activeController = self.activeController {
      self.stopDisplayingChildViewController(activeController)
    }

    self.displayChildViewController(controller)
    self.activeController = controller
  }

  func displayChildViewController(_ controller: UIViewController) {
    guard let childView = controller.view else {
      return
    }

    controller.beginAppearanceTransition(true, animated: true)

    addChild(controller)

    self.view.addSubview(childView)

    childView.translatesAutoresizingMaskIntoConstraints = false
    childView.topAnchor.constraint(equalTo: self.toggle.bottomAnchor).isActive = true
    childView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
    childView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
    childView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

    controller.didMove(toParent: self)

    controller.endAppearanceTransition()
  }

  func stopDisplayingChildViewController(_ controller: UIViewController) {
    controller.beginAppearanceTransition(false, animated: true)

    controller.willMove(toParent: nil)
    for constraint in controller.view.constraints {
      constraint.isActive = false
    }
    controller.view.removeFromSuperview()
    controller.removeFromParent()

    controller.endAppearanceTransition()
  }
}
