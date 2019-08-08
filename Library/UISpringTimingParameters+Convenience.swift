import Foundation
import UIKit

// Derived from https://github.com/jenox/UIKit-Playground/tree/master/01-Demystifying-UIKit-Spring-Animations/
public extension UISpringTimingParameters {
  convenience init(dampingRatio: CGFloat, frequencyResponse: CGFloat) {
    precondition(dampingRatio >= 0)
    precondition(frequencyResponse > 0)

    let mass = CGFloat(1.0)
    let stiffness = pow(2 * .pi / frequencyResponse, 2) * mass
    let damping = 4 * .pi * dampingRatio * mass / frequencyResponse

    self.init(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: .zero)
  }
}
