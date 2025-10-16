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
                    autoacceptMinPrecision: 0.4,
                    autoAcceptMinSeparation: 0.05
                )
            } viewForSuggestion: { score in
                Text("\(score.identifier.rawValue)")
                    .font(.largeTitle.weight(.black))
                    .frame(width: 44.0, height: 44.0)
            }
            .clearOnSuggestionAccepted()
            .onSuggestionAccepted { score in
                print("Accepted suggestion \(score)")
            }
            .limitSuggestions(max: 3)
        }
    }
}
