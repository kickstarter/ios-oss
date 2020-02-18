import Foundation
import UIKit
import SpriteKit
import Library
import KsApi

public final class CategorySelectionViewController: UITableViewController {
  private lazy var skView: SKView = {
    return SKView(frame: self.view.bounds)
  }()
  private lazy var skScene: SKScene = {
    return SKScene(size: self.view.bounds.size)
  }()
  private let viewModel: CategorySelectionViewModelType = CategorySelectionViewModel()
  private let dataSource = CategorySelectionDataSource()

  override public func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = dataSource

//    self.view.backgroundColor = .ksr_grey_200
//
//    self.view.addSubview(skView)
//
//    skScene.backgroundColor = .ksr_grey_200
//    skScene.anchorPoint = .zero
//    skScene.physicsWorld.gravity = .zero
//    skScene.physicsBody = SKPhysicsBody(edgeLoopFrom: skView.frame)
//
//    let radialFieldNode = SKFieldNode.radialGravityField()
//    radialFieldNode.strength = 2.0
//    radialFieldNode.position = skView.center
//    radialFieldNode.isEnabled = true
//    radialFieldNode.minimumRadius = Float(self.view.bounds.size.width / 2)
//
//    skScene.addChild(radialFieldNode)
//
//    skView.presentScene(skScene)

    self.tableView.registerCellClass(CategorySelectionCell.self)

    self.viewModel.inputs.viewDidLoad()
  }

  override public func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.loadCategorySections
      .observeForUI()
      .observeValues { [weak self] categories in
        self?.dataSource.load(categories: categories)
        self?.tableView.reloadData()
    }
  }

  private func configureNodes(categoryNodes: [KsApi.Category]) {
    categoryNodes.forEach { category in
      let font = UIFont.ksr_callout()
      let radius: CGFloat = 50

      let label = SKLabelNode(text: category.name)
      label.fontName = font.fontName
      label.fontSize = font.pointSize
      label.numberOfLines = 2
      label.lineBreakMode = .byWordWrapping
      label.fontColor = .black
      label.verticalAlignmentMode = .center
      label.text = category.name
      label.preferredMaxLayoutWidth = radius * 2

      let node = SKShapeNode(circleOfRadius: radius)
      node.fillColor = .ksr_red_400
      node.strokeColor = .ksr_red_400
//      node.position = CGPoint(x: 10 * index, y: 200)
      let physicsBody = SKPhysicsBody(circleOfRadius: radius)
      physicsBody.mass = CGFloat(radius)
      physicsBody.linearDamping = 3
      physicsBody.allowsRotation = false
      physicsBody.restitution = 0.6
      physicsBody.friction = 0

      node.physicsBody = physicsBody
      node.addChild(label)

      skScene.addChild(node)
    }
  }
}
