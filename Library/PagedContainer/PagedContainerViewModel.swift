import Combine
import Foundation
import UIKit

public class PagedContainerViewModel {
  // Internal
  private var subscriptions = Set<AnyCancellable>()

  init() {
    self.pageTitles = self.configureWithChildrenSubject.map { controllers in
      controllers.map { $0.title ?? "Page " }
    }.eraseToAnyPublisher()

    self.displayChildViewControllerAtIndex = Publishers.CombineLatest(
      self.configureWithChildrenSubject,
      self.selectedIndex.compactMap { $0 }
    )
    .map { (controllers: [UIViewController], index: Int) -> (UIViewController, Int)? in
      if index < controllers.count {
        return (controllers[index], index)
      } else {
        return nil
      }
    }.compactMap { $0 }
    .eraseToAnyPublisher()
  }

  // Inputs
  func viewWillAppear() {
    if self.selectedIndex.value == nil {
      self.didSelectPage(atIndex: 0)
    }
  }

  private let configureWithChildrenSubject = CurrentValueSubject<[UIViewController], Never>([])
  func configure(withChildren children: [UIViewController]) {
    self.configureWithChildrenSubject.send(children)
  }

  private let selectedIndex = CurrentValueSubject<Int?, Never>(nil)
  func didSelectPage(atIndex index: Int) {
    self.selectedIndex.send(index)
  }

  // Outputs
  public let displayChildViewControllerAtIndex: AnyPublisher<(UIViewController, Int), Never>
  public let pageTitles: AnyPublisher<[String], Never>
}
