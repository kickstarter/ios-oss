import Foundation
import GraphAPI

extension LastWave {
  init(fromFragment fragment: GraphAPI.LastWaveFragment) {
    self.id = decompose(id: fragment.id) ?? 0
    self.active = fragment.active
  }
}
