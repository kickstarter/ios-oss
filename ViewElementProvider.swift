import Alamofire
import AlamofireImage
import Foundation

protocol ViewElementProviderDelegate: AnyObject {
  func reloadTableView()
}

class ViewElementProvider {
  weak var delegate: ViewElementProviderDelegate?

  private(set) var displayElements = [ViewElement]()

  private var viewElements: [ViewElement]?
  private var loadedIndex: Int = 0 {
    didSet {
      guard let viewElements = viewElements else { return }
      displayElements = Array(viewElements[..<loadedIndex])
    }
  }

  func set(viewElements: [ViewElement]?) {
    self.viewElements = viewElements
    self.loadImages(startIndex: 0, elementBatchSize: 10)
  }

  private func loadImages(startIndex: Int, elementBatchSize: Int) {
    guard let viewElements = viewElements else { return }
    let adjustedStartIndex = min(startIndex, viewElements.count)
    let endIndex = min(startIndex + elementBatchSize, viewElements.count)
    var remainingElementsInBatch = endIndex - startIndex

    for i in adjustedStartIndex..<endIndex {
      let element = viewElements[i]
      guard let imageElement = element as? ImageViewElement, imageElement.image == nil else {
        remainingElementsInBatch -= 1
        self.checkBatch(
          remainingElements: remainingElementsInBatch,
          startIndex: startIndex,
          endIndex: endIndex,
          batchSize: elementBatchSize
        )
        continue
      }

      AF.request(imageElement.src).responseImage { [weak self] response in
        if case let .success(image) = response.result {
          print("image downloaded: \(image)")
          imageElement.image = image
        }
        remainingElementsInBatch -= 1
        self?.checkBatch(
          remainingElements: remainingElementsInBatch,
          startIndex: startIndex,
          endIndex: endIndex,
          batchSize: elementBatchSize
        )
      }
    }
  }

  private func checkBatch(remainingElements: Int, startIndex: Int, endIndex: Int, batchSize: Int) {
    if remainingElements == 0 {
      self.loadedIndex = endIndex
      self.delegate?.reloadTableView()
      self.loadImages(startIndex: startIndex + batchSize, elementBatchSize: batchSize)
    }
  }
}
