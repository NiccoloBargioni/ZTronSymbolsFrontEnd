import Foundation
import ZTronSymbolsClassifier
import ZTronObservation

public final class SuggestionsModel<H: Hashable>: ObservableObject, AnySuggestionModel {
    public var id: String = "suggestions model"
    @Published internal var suggestions: [Score<H>] = .init()
    private let classifier = Classifier<H>(samplelimit: Int.max - 1)
    @InteractionsManaging(setupOr: .ignore, detachOr: .ignore) private var delegate: (any MSAInteractionsManager)? = nil
    
    private let shouldAutoassignToMostLikely: Bool
    private let timeBeforeAutoassign: DispatchTimeInterval
    private var autoassignWorkItem: DispatchWorkItem? = nil
    private var onSuggestionAcceptedAction: ((Score<H>) -> Void)? = nil
    
    public init(
        mediator: MSAMediator,
        autoAssignToMostLikely: Bool = false,
        timeBeforeAutoassign: DispatchTimeInterval = .seconds(2)
    ) {
        self.shouldAutoassignToMostLikely = autoAssignToMostLikely
        self.timeBeforeAutoassign = timeBeforeAutoassign
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

    public func updateSuggestions(
        for test: Strokes,
        completion: (() -> Void)?
    ) {
        self.autoassignWorkItem?.cancel()
        
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
            
            completion?()
        }
    }
    
    public final func addTrainingPoint(example: Strokes, class: H) {
        self.classifier.train(identifier: `class`, sample: StrokeSample(strokes: example.sanitize()))
    }
    
    public final func getSuggestions() -> [Score<H>] {
        return self.suggestions
    }
    
    public final func onStrokeEnded() {
        guard self.shouldAutoassignToMostLikely else { return }
        guard let mostLikelySymbol = self.suggestions.first else { return }
        
        self.autoassignWorkItem?.cancel()
        
        self.autoassignWorkItem = DispatchWorkItem {
            self.onSuggestionAcceptedAction?(mostLikelySymbol)
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + self.timeBeforeAutoassign,
            execute: self.autoassignWorkItem!
        )
    }
    
    public func onSuggestionAccepted(_ action: ((Score<H>) -> Void)?) {
        self.onSuggestionAcceptedAction = action
    }

}
