import ZTronObservation
import UIKit
import SwiftUI


public struct AutographView<S: AnySuggestionModel & ObservableObject>: UIViewControllerRepresentable {
    weak private var mediator: MSAMediator?
    weak private var model: DrawingFragmentModel?
    weak private var suggestionsModel: S?
    
    public init(
        mediator: MSAMediator,
        fragmentModel: DrawingFragmentModel,
        suggestionsModel: S
    ) {
        self.mediator = mediator
        self.model = fragmentModel
        self.suggestionsModel = suggestionsModel
    }
    
    public func makeUIViewController(context: Context) -> AutographViewController<S> {
        guard let mediator = self.mediator else { fatalError() }
        guard let fragmentModel = self.model else { fatalError() }
        guard let suggestionsModel = self.suggestionsModel else { fatalError() }
        
        return AutographViewController(
            mediator: mediator,
            fragmentModel: fragmentModel,
            suggestionsModel: suggestionsModel
        )
    }
    
    public func updateUIViewController(_ uiViewController: AutographViewController<S>, context: Context) {
        
    }
}
