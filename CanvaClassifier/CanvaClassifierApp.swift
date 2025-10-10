import SwiftUI

@main
struct CanvaClassifierApp: App {
    var body: some Scene {
        WindowGroup {
            CanvaClassifierView(trainingSet: UppercaseAlphabetTraining.trainingData) { mediator in
                return SuggestionsModel<Alphabet>(
                    mediator: mediator,
                    autoAssignToMostLikely: true,
                    timeBeforeAutoassign: .milliseconds(750)
                )
            } viewForSuggestion: { score in
                Text("\(score.identifier.rawValue)")
            }
            .onSuggestionAccepted { score in
                print("Accepted suggestion \(score)")
            }
            .clearOnSuggestionAccepted()
        }
    }
}
