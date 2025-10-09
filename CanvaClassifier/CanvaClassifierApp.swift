import SwiftUI

@main
struct CanvaClassifierApp: App {
    var body: some Scene {
        WindowGroup {
            CanvaClassifierView(trainingSet: alphabetTrainingSet) { mediator in
                return SuggestionsModel<Alphabet>(mediator: mediator)
            } viewForSuggestion: { score in
                Text("\(score.identifier.rawValue)")
            }
        }
    }
}
