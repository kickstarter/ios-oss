import Foundation
import UIKit

class ImageViewElement: ViewElement {
    let src: String
    var image: UIImage?

    init(src: String) {
        self.src = src
    }
}
