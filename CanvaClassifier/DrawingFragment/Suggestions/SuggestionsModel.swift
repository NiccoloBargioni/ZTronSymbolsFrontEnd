import Foundation
import ZTronSymbolsClassifier
import ZTronObservation


public final class SuggestionsModel: ObservableObject, Component {
    public var id: String = "suggestions model"
    @Published internal var suggestions: [Score<Alphabet>] = .init()
    private let classifier = Classifier<Alphabet>(samplelimit: Int.max - 1)
    @InteractionsManaging(setupOr: .ignore, detachOr: .ignore) private var delegate: (any MSAInteractionsManager)? = nil
    
    
    public init(mediator: MSAMediator) {
        self.delegate = SuggestionInteractionsManager(owner: self, mediator: mediator)
        
        for symbol in alphabetTrainingSet.keys {
            for strokes in alphabetTrainingSet[symbol]! {
                self.classifier.train(identifier: symbol, sample: StrokeSample(strokes: strokes.sanitize()))
            }
        }

    }
    
    public func setDelegate(_ interactionsManager: (any ZTronObservation.InteractionsManager)?) {
        guard let interactionsManager = interactionsManager as? MSAInteractionsManager else {
            if interactionsManager == nil {
                self.delegate = nil
                return
            } else {
                fatalError("Expected interactions manager of type \(String(describing: MSAInteractionsManager.self))")
            }
        }
        
        self.delegate = interactionsManager
    }
    
    public func getDelegate() -> (any ZTronObservation.InteractionsManager)? {
        return self.delegate
    }
    
    public static func == (lhs: SuggestionsModel, rhs: SuggestionsModel) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    public func updateSuggestions(for test: Strokes) {
        guard test.count > 0 else {
            self.suggestions = []
            return
        }
        
        self.suggestions = self.classifier.classify(sampleType: StrokeSample.self, unknown: StrokeSample(strokes: test.sanitize()))
    }
}
