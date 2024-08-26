import Combine
import Foundation
import SwiftUI
import UIKit

public protocol TabBarPage: Identifiable {
  var name: String { get }
  var badgeCount: Int? { get }
}

public protocol PagedContainerViewModelInputs {
  associatedtype Page: TabBarPage

  func viewWillAppear()
  func configure(with children: [(Page, UIViewController)])
  func didSelect(page: Page)
}

public protocol PagedContainerViewModelOutputs: ObservableObject {
  associatedtype Page: TabBarPage

  var displayPage: (page: Page, viewController: UIViewController)? { get }
  var pages: [(page: Page, viewController: UIViewController)] { get }
}

public class PagedContainerViewModel<Page: TabBarPage>: PagedContainerViewModelInputs,
  PagedContainerViewModelOutputs, ObservableObject {
  init() {
    Publishers.CombineLatest(
      self.configureWithChildrenSubject,
      self.selectedPageSubject
    )
    .compactMap { combined -> (Page, UIViewController)? in
      let (pages, selectedPage) = combined
      return pages.first(where: { result in
        let (page, _) = result
        return page.id == selectedPage?.id
      })
    }
    .sink(receiveValue: { page in
      self.displayPage = page
    })
    .store(in: &self.subscriptions)

    self.configureWithChildrenSubject
      .sink { pages in
        self.pages = pages
      }
      .store(in: &self.subscriptions)

    self.viewWillAppearSubject
      .combineLatest(self.selectedPageSubject) { _, selectedPage in selectedPage }
      .filter { $0 == nil }
      .combineLatest(self.$pages) { _, pages in pages }
      .compactMap { pages in
        if let (firstPage, _) = pages.first {
          return firstPage
        } else {
          return nil
        }
      }
      .first()
      .sink { [weak self] page in
        self?.selectedPageSubject.send(page)
      }
      .store(in: &self.subscriptions)
  }

  // Inputs
  public func viewWillAppear() {
    self.viewWillAppearSubject.send(())
  }

  public func configure(with children: [(Page, UIViewController)]) {
    self.configureWithChildrenSubject.send(children)
  }

  public func didSelect(page: Page) {
    if self.selectedPageSubject.value?.id != page.id {
      self.selectedPageSubject.send(page)
    }
  }

  // Outputs
  @Published public private(set) var displayPage: (page: Page, viewController: UIViewController)?
  @Published public private(set) var pages: [(page: Page, viewController: UIViewController)] = []

  // Internal
  private var subscriptions = Set<AnyCancellable>()

  private let viewWillAppearSubject = PassthroughSubject<Void, Never>()
  private let configureWithChildrenSubject = CurrentValueSubject<[(Page, UIViewController)], Never>([])
  private let selectedPageSubject = CurrentValueSubject<Page?, Never>(nil)
}
