import Foundation

extension Project.Country {
  static func country(from graphCountry: GraphCountry) -> Project.Country? {
    guard let country = Project.Country.all
      .first(where: { $0.countryCode == graphCountry.code }) else { return nil }

    return country
  }
}
