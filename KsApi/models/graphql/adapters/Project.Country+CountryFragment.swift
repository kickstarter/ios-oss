import Foundation

extension Project.Country {
  static func country(from countryFragment: GraphAPI.CountryFragment) -> Project.Country? {
    guard let country = Project.Country.all
      .first(where: { $0.countryCode == countryFragment.code.rawValue }) else { return nil }

    return country
  }
}
