import SwiftUI

@main
struct CanvaClassifierApp: App {
    var body: some Scene {
        WindowGroup {
            CanvaClassifierView(trainingSet: UppercaseAlphabetTraining.trainingData) { mediator in
                return SuggestionsModel<Alphabet>(
                    mediator: mediator,
                    autoAssignToMostLikely: true,
                    timeBeforeAutoassign: .milliseconds(750),
                    autoacceptMinPrecision: 0.69,
                    autoAcceptMinSeparation: 0.02
                )
            } viewForSuggestion: { score in
                Text("\(score.identifier.rawValue)")
                    .layoutPriority(1)
            }
            .onSuggestionAccepted { score in
                print("Accepted suggestion \(score)")
            }
            .clearOnSuggestionAccepted()
            .limitSuggestions(max: 3)
        }
    }
}
