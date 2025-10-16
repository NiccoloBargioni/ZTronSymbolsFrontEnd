import Foundation
import ZTronSymbolsClassifier
import ZTronObservation

public final class SuggestionsModel<H: Hashable>: ObservableObject, AnySuggestionModel {
    public var id: String = "suggestions model"
    @Published internal var suggestions: [Score<H>] = .init()
    private let classifier = Classifier<H>(samplelimit: Int.max - 1)
    @InteractionsManaging(setupOr: .ignore, detachOr: .ignore) private var delegate: (any MSAInteractionsManager)? = nil
    
    @Published private var precisions: [H: Double] = [:]
    
    private let shouldAutoassignToMostLikely: Bool
    private let timeBeforeAutoassign: DispatchTimeInterval
    private var autoassignWorkItem: DispatchWorkItem? = nil
    private var onSuggestionAcceptedAction: ((Score<H>) -> Void)? = nil
    private let autoacceptMinPrecision: Double
    private let autoacceptMinSeparation: Double
    private var onDisambiguationNeededAction: (([Score<H>]) -> Void)?
    
    public init(
        mediator: MSAMediator,
        autoAssignToMostLikely: Bool = false,
        timeBeforeAutoassign: DispatchTimeInterval = .seconds(2),
        autoacceptMinPrecision: Double = 0.0,
        autoAcceptMinSeparation: Double = 0.0
    ) {
        self.shouldAutoassignToMostLikely = autoAssignToMostLikely
        self.timeBeforeAutoassign = timeBeforeAutoassign
        self.autoacceptMinPrecision = autoacceptMinPrecision
        self.autoacceptMinSeparation = autoAcceptMinSeparation
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
            
            if let precisionOfMostLikelySymbol = self.precisions[mostLikelySymbol.identifier] {
                if precisionOfMostLikelySymbol >= self.autoacceptMinPrecision {
                    if self.suggestions.count > 1 {

                        if abs(self.suggestions[0].score - self.suggestions[1].score) >= self.autoacceptMinSeparation {
                            self.onSuggestionAcceptedAction?(mostLikelySymbol)
                        } else {
                            self.onDisambiguationNeededAction?(Array(self.suggestions.prefix(2)))
                        }
                    } else {
                        self.onSuggestionAcceptedAction?(mostLikelySymbol)
                    }
                }
            } else {
                self.onSuggestionAcceptedAction?(mostLikelySymbol)
            }
        }

        DispatchQueue.main.asyncAfter(
            deadline: .now() + self.timeBeforeAutoassign,
            execute: self.autoassignWorkItem!
        )
    }
    
    public func onSuggestionAccepted(_ action: ((Score<H>) -> Void)?) {
        self.onSuggestionAcceptedAction = action
    }

    
    public func estimatePrecisions(trainingSet: [H: [[Stroke]]]) {
        var trainingSetOfSamples: [H: [StrokeSample]] = [:]

        
        for letter in trainingSet.keys {
            if let examples = trainingSet[letter] {
                trainingSetOfSamples[letter] = []
                for example in examples {
                    trainingSetOfSamples[letter]?.append(StrokeSample(strokes: example))
                }
            }
        }

        let classifierMetrics = self.classifier.kFoldCrossValidate(k: 10, from: trainingSetOfSamples)
        
        var updatedPrecisions: [H: Double] = [:]
        
        classifierMetrics.keys.forEach { symbol in
            if let metricsForSymbol = classifierMetrics[symbol] {
                updatedPrecisions[symbol] = metricsForSymbol.getMeanPrecision()
            }
        }
        
        updatedPrecisions.keys.forEach { symbol in
            if let precisionForSymbol = updatedPrecisions[symbol] {
                self.precisions[symbol] = precisionForSymbol
            }
        }
    }

    
    public func getEstimatedPrecision(for symbol: H) -> Double? {
        return self.precisions[symbol]
    }
    
    public func onDisambiguationNeeded(_ action: @escaping ([Score<H>]) -> Void) {
        self.onDisambiguationNeededAction = action
    }
}
