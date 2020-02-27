import Foundation
import KsApi
import Library
import Prelude
import SpriteKit
import UIKit

public final class CategorySelectionViewController: UIViewController {
  private let viewModel: CategorySelectionViewModelType = CategorySelectionViewModel()
  private let dataSource = CategorySelectionDataSource()

  private lazy var tableView: UITableView = {
    UITableView(frame: .zero, style: .plain)
      |> \.allowsSelection .~ false
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var headerView: UIView = {
    CategorySelectionHeaderView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var buttonsView: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var continueButton: UIButton = { UIButton(type: .custom) }()
  private lazy var skipButton: UIBarButtonItem = {
    UIBarButtonItem(title: Strings.general_navigation_buttons_skip(),
                    style: .plain,
                    target: self,
                    action: #selector(CategorySelectionViewController.skipButtonTapped))
  }()
  private lazy var buttonsStackView: UIStackView = { UIStackView(frame: .zero) }()

  public override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> baseControllerStyle()

    _ = self.navigationController?.navigationBar
      ?|> \.backgroundColor .~ .clear
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ true

    _ = self.tableView
    |> \.dataSource .~ self.dataSource
    |> \.estimatedRowHeight .~ 100
    |> \.separatorStyle .~ .none
    |> \.contentInsetAdjustmentBehavior .~ .never
    |> \.rowHeight .~ UITableView.automaticDimension

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

    self.navigationItem.setRightBarButton(self.skipButton, animated: false)

    self.tableView.registerCellClass(CategorySelectionCell.self)

    self.configureSubviews()
    self.setupConstraints()

    self.viewModel.inputs.viewDidLoad()
  }

  override public var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override public func bindStyles() {
    super.bindStyles()

    _ = self.skipButton
      |> \.tintColor .~ .white

    _ = self.headerView
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.buttonsView
      |> \.backgroundColor .~ .white
      |> \.layoutMargins .~ .init(all: Styles.grid(2))
      |> \.layer.shadowColor .~ UIColor.black.cgColor
      |> \.layer.shadowOpacity .~ 0.12
      |> \.layer.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.layer.shadowRadius .~ CGFloat(1.0)

    _ = self.buttonsStackView
      |> verticalStackViewStyle

    _ = self.continueButton
      |> greyButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.tableView.contentInset.bottom = self.buttonsView.frame.height
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] categories in
        self?.dataSource.load(categories: categories)
        self?.tableView.reloadData()
      }
  }

  private func configureSubviews() {
    _ = (self.headerView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.tableView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsView, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.buttonsStackView, self.buttonsView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = ([self.continueButton], self.buttonsStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.headerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.headerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      self.tableView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor),
      self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonsView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.buttonsView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.buttonsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    ])
  }

  // MARK: - Accessors

  @objc func skipButtonTapped() {
    self.dismiss(animated: true)
  }
}
