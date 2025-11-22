import Foundation
import Combine

// Placeholder for Phase 6
class TextSearchViewModel: ObservableObject {
    @Published var matchedTexts: [TextResult] = []
    @Published var searchQuery: String = ""
}
