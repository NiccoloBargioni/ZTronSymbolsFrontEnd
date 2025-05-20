import SwiftUI
import ZTronObservation
import ZTronSymbolsClassifier

public struct ContentView: View {
    private var mediator: MSAMediator = .init()
    @StateObject private var pageModel: DrawingPageModel
    @StateObject private var fragmentModel: DrawingFragmentModel
    @StateObject private var suggestionsModel: SuggestionsModel

    public init() {
        let mediator = self.mediator
        self._pageModel = StateObject(wrappedValue: DrawingPageModel(mediator: mediator))
        self._fragmentModel = StateObject(wrappedValue: DrawingFragmentModel(mediator: mediator))
        self._suggestionsModel = StateObject(wrappedValue: SuggestionsModel(mediator: mediator))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AutographView(mediator: self.mediator, fragmentModel: self.fragmentModel, suggestionsModel: self.suggestionsModel)
                .overlay(alignment: .bottom) {
                    HStack(alignment: .center, spacing: 18) {
                        if self.suggestionsModel.suggestions.count > 0 {
                            ForEach(self.suggestionsModel.suggestions) { suggestion in
                                VStack(alignment: .center, spacing: 18) {
                                    Image("SSRC_\(suggestion.identifier.rawValue)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 55.0)
                                    
                                    Text("\(suggestion.score, specifier: "%.2f")")
                                        .font(.footnote.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            
            HStack(alignment: .center, spacing: 0) {
                Button {
                    self.pageModel.sendSave()
                } label: {
                    Image(systemName: "square.and.arrow.down.fill")
                        .font(.system(size: 18, weight: .medium))
                        .padding()
                }
                
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
        }
    }
}

public struct AutographView: UIViewControllerRepresentable {
    weak private var mediator: MSAMediator?
    weak private var model: DrawingFragmentModel?
    weak private var suggestionsModel: SuggestionsModel?
    
    public init(mediator: MSAMediator, fragmentModel: DrawingFragmentModel, suggestionsModel: SuggestionsModel?) {
        self.mediator = mediator
        self.model = fragmentModel
        self.suggestionsModel = suggestionsModel
    }
    
    public func makeUIViewController(context: Context) -> AutographViewController {
        guard let mediator = self.mediator else { fatalError() }
        guard let fragmentModel = self.model else { fatalError() }
        guard let suggestionsModel = self.suggestionsModel else { fatalError() }
        
        return AutographViewController(mediator: mediator, fragmentModel: fragmentModel, suggestionsModel: suggestionsModel)
    }
    
    public func updateUIViewController(_ uiViewController: AutographViewController, context: Context) {
        
    }
}


extension Score: Identifiable {
    public var id: ID {
        return self.identifier
    }
}
