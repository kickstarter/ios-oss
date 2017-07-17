import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

internal final class LiveStreamContainerPageViewController: UIViewController {
  @IBOutlet private weak var chatPagerButton: UIButton!
  @IBOutlet private weak var indicatorLineView: UIView!
  @IBOutlet private weak var indicatorLineViewXConstraint: NSLayoutConstraint!
  @IBOutlet private weak var infoPagerButton: UIButton!
  @IBOutlet private weak var pagerTabStripStackView: UIStackView!
  @IBOutlet private weak var separatorView: UIView!

  fileprivate var pagesDataSource = LiveStreamContainerPagesDataSource()
  fileprivate weak var pageViewController: UIPageViewController?
  fileprivate let viewModel: LiveStreamContainerPageViewModelType = LiveStreamContainerPageViewModel()

  internal func configureWith(project: Project,
                              liveStreamEvent: LiveStreamEvent,
                              refTag: RefTag,
                              presentedFromProject: Bool) {
    self.viewModel.inputs.configureWith(project: project,
                                        liveStreamEvent: liveStreamEvent,
                                        refTag: refTag,
                                        presentedFromProject: presentedFromProject)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.chatPagerButton.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
    self.infoPagerButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

    self.pageViewController = self.childViewControllers
      .flatMap { $0 as? UIPageViewController }
      .first

    self.pageViewController?.dataSource = self.pagesDataSource
    self.pageViewController?.delegate = self

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseLiveStreamControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_dark_grey_500

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

    _ = self.indicatorLineView
      |> UIView.lens.backgroundColor .~ .white

    _ = self.pagerTabStripStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(topBottom: Styles.grid(2))

    _ = self.infoPagerButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Info() }

    _ = self.chatPagerButton
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.Chat() }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadViewControllersIntoPagesDataSource
      .observeForUI()
      .observeValues { [weak self] in
        self?.loadViewControllersIntoPagesDataSource(pages: $0)
    }

    self.viewModel.outputs.chatButtonTextColor
      .observeForUI()
      .observeValues { [weak self] in
        self?.chatPagerButton.setTitleColor($0, for: .normal)
    }

    self.viewModel.outputs.chatButtonTitleFont
      .observeForUI()
      .observeValues { [weak self] in
        self?.chatPagerButton.titleLabel?.font = $0
    }

    self.viewModel.outputs.infoButtonTextColor
      .observeForUI()
      .observeValues { [weak self] in
        self?.infoPagerButton.setTitleColor($0, for: .normal)
    }

    self.viewModel.outputs.infoButtonTitleFont
      .observeForUI()
      .observeValues { [weak self] in
        self?.infoPagerButton.titleLabel?.font = $0
    }

    self.viewModel.outputs.indicatorLineViewXPosition
      .observeForUI()
      .observeValues { [weak self] in
        self?.animateIndicatorLineViewToPosition(position: $0)
    }

    self.viewModel.outputs.pagedToPage
      .observeForUI()
      .observeValues { [weak self] page, direction in
        self?.pagesDataSource.controller(forPage: page).doIfSome {
          self?.pageViewController?.setViewControllers([$0], direction: direction, animated: true,
                                                       completion: nil)
        }
    }

    self.viewModel.outputs.pagerTabStripStackViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.pagerTabStripStackView.isHidden = $0
    }

    self.viewModel.outputs.indicatorLineViewHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.indicatorLineView.isHidden = $0
    }
  }

  @objc private func infoButtonTapped() {
    self.viewModel.inputs.infoButtonTapped()
  }

  @objc internal func chatButtonTapped() {
    self.viewModel.inputs.chatButtonTapped()
  }

  private func loadViewControllersIntoPagesDataSource(pages: [LiveStreamContainerPage]) {
    self.pagesDataSource.load(pages: pages)
    self.viewModel.inputs.didLoadViewControllersIntoPagesDataSource()
  }

  private func animateIndicatorLineViewToPosition(position: Int) {
    UIView.animate(withDuration: 0.3) {
      self.indicatorLineViewXConstraint.constant = self.indicatorLineView.frame.size.width * CGFloat(position)
    }
  }
}

extension LiveStreamContainerPageViewController: UIPageViewControllerDelegate {
  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]) {

    guard let page = pendingViewControllers.first.flatMap(self.pagesDataSource.page(forController:)) else {
      return
    }

    self.viewModel.inputs.willTransition(toPage: page)
  }
}
