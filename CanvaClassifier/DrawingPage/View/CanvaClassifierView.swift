import SwiftUI
import ZTronObservation
import ZTronSymbolsClassifier

public struct CanvaClassifierView<
    S: AnySuggestionModel & ObservableObject,
    V: View
>: View {
    private var mediator: MSAMediator = .init()
    @StateObject private var pageModel: DrawingPageModel
    @StateObject private var fragmentModel: DrawingFragmentModel
    @StateObject private var suggestionsModel: S
    
    @State private var suggestions: [Score<S.H>] = []
    private var viewForSuggestion: ((Score<S.H>) -> V)? = nil
    private var onSuggestionAcceptedAction: ((Score<S.H>) -> Void)? = nil
    private var limitSuggestions: Int? = nil
    
    private let trainingSet: [S.H: [Strokes]]
    private var shouldClearOnSuggestionAccepted: Bool = false

    public init(
        trainingSet: [S.H: [Strokes]],
        suggestionsModel: @escaping (MSAMediator) -> S,
        @ViewBuilder viewForSuggestion: @escaping (Score<S.H>) -> V
    ) {
        let mediator = self.mediator
        self._pageModel = StateObject(wrappedValue: DrawingPageModel(mediator: mediator))
        self._fragmentModel = StateObject(wrappedValue: DrawingFragmentModel(mediator: mediator))
        self._suggestionsModel = StateObject(wrappedValue: suggestionsModel(mediator))
        self.viewForSuggestion = viewForSuggestion
        self.trainingSet = trainingSet
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AutographView(
                mediator: self.mediator,
                fragmentModel: self.fragmentModel,
                suggestionsModel: self.suggestionsModel
            )
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 18) {
                        if self.suggestionsModel.getSuggestions().count > 0 {
                            ForEach(
                                self.suggestions
                                    .prefix(max(0, min(self.suggestions.count, self.limitSuggestions ?? self.suggestions.count))),
                                id: \.self
                            ) { suggestion in
                                Button {
                                    self.onSuggestionAcceptedAction?(suggestion)
                                    
                                    if self.shouldClearOnSuggestionAccepted {
                                        self.pageModel.sendClear()
                                    }
                                } label: {
                                    if let viewForSuggestion = viewForSuggestion {
                                        viewForSuggestion(suggestion)
                                    } else {
                                        Text("\(String(describing: suggestion.id))")
                                    }
                                }
                                .tint(.primary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onChange(of: self.suggestionsModel.getSuggestions()) { newSuggestionsSet in
                self.suggestions = newSuggestionsSet
            }
            
            HStack(alignment: .center, spacing: 0) {
                Button {
                    self.pageModel.sendClear()
                } label: {
                    Image(systemName: "eraser.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
                Button {
                    self.pageModel.sendUndoLastStroke()
                } label: {
                    Image(systemName: "arrow.uturn.left")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                .disabled(self.pageModel.isUndoButtonDisabled)
            }
            .tint(.primary)
        }
        .task {
            self.suggestionsModel.setDelegate(SuggestionInteractionsManager(owner: self.suggestionsModel, mediator: self.mediator))
            
            self.suggestionsModel.onSuggestionAccepted { score in
                self.onSuggestionAcceptedAction?(score)
            }
        }
        .task {
            for symbol in self.trainingSet.keys {
                for strokes in self.trainingSet[symbol]! {
                    self.suggestionsModel.addTrainingPoint(
                        example: strokes,
                        class: symbol
                    )
                }
            }
        }
    }
    
    public func onSuggestionAccepted(_ action: @escaping (Score<S.H>) -> Void) -> Self {
        var copy = self
        copy.onSuggestionAcceptedAction = action
        return copy
    }
    
    public func clearOnSuggestionAccepted(_ shouldClear: Bool = true) -> Self {
        var copy = self
        copy.shouldClearOnSuggestionAccepted = shouldClear
        return copy
    }
    
    public func limitSuggestions(max: Int?) -> Self {
        var copy = self
        copy.limitSuggestions = max
        return copy
    }
}


extension Score: @retroactive Identifiable {
    public var id: ID {
        return self.identifier
    }
}

extension Score: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

