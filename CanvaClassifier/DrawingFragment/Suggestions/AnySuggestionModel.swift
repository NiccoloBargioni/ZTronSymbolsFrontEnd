import ZTronObservation
import ZTronSymbolsClassifier

public protocol AnySuggestionModel: Component {
    associatedtype H: Hashable
    
    func addTrainingPoint(example: Strokes, class: H) -> Void
    func updateSuggestions(for test: Strokes, completion: (() -> Void)?) -> Void
    func estimatePrecisions(trainingSet: [H: [[Stroke]]]) -> Void
    
    func onStrokeEnded() -> Void
    func getSuggestions() -> [Score<H>]
    func onSuggestionAccepted(_:((Score<H>) -> Void)?)

    func getEstimatedPrecision(for symbol: H) -> Double?
    func onDisambiguationNeeded(_: @escaping ([Score<H>]) -> Void)
}
