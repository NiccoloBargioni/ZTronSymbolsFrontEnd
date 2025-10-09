import Foundation
import ZTronSymbolsClassifier
import ZTronObservation

public final class SuggestionsModel<H: Hashable>: ObservableObject, AnySuggestionModel {
    
    public var id: String = "suggestions model"
    @Published internal var suggestions: [Score<H>] = .init()
    private let classifier = Classifier<H>(samplelimit: Int.max - 1)
    @InteractionsManaging(setupOr: .ignore, detachOr: .ignore) private var delegate: (any MSAInteractionsManager)? = nil
    
    
    public init(mediator: MSAMediator) {
        self.delegate = SuggestionInteractionsManager(owner: self, mediator: mediator)
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
            Task(priority: .userInitiated) { @MainActor in
                self.suggestions = []
            }
            return
        }
        
        let newSuggestions = self.classifier.classify(
            sampleType: StrokeSample.self,
            unknown: StrokeSample(strokes: test.sanitize())
        )
        
        Task(priority: .userInitiated) { @MainActor in
            self.suggestions = newSuggestions
        }
    }
    
    public final func addTrainingPoint(example: Strokes, class: H) {
        self.classifier.train(identifier: `class`, sample: StrokeSample(strokes: example.sanitize()))
    }
    
    public final func getSuggestions() -> [Score<H>] {
        return self.suggestions
    }
}
