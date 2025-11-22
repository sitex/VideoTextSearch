import Foundation

class TextSearchMatcher {
    var searchQuery: String = ""

    func findMatches(in textResults: [TextResult]) -> [TextResult] {
        guard !searchQuery.isEmpty else {
            return []
        }

        return textResults.filter { result in
            result.text.localizedCaseInsensitiveContains(searchQuery)
        }
    }
}
