import Foundation
import ZTronObservation

public final class SuggestionInteractionsManager: MSAInteractionsManager, @unchecked Sendable {
    weak private var owner: SuggestionsModel?
    weak private var mediator: MSAMediator?
    
    public init(owner: SuggestionsModel, mediator: MSAMediator) {
        self.owner = owner
        self.mediator = mediator
    }
    
    public func peerDiscovered(eventArgs: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let fragmentModel = eventArgs.getSource() as? DrawingFragmentModel {
            mediator?.signalInterest(owner, to: fragmentModel)
        }
    }
    
    public func peerDidAttach(eventArgs: ZTronObservation.BroadcastArgs) {
        
    }
    
    public func notify(args: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let fragmentModel = args.getSource() as? DrawingFragmentModel {
            let shouldUpdate = fragmentModel.strokes.reduce(true) { shouldUpdate, nextStroke in
                return shouldUpdate && nextStroke.count > 1
            }
            
            if shouldUpdate {
                Task(priority: .medium) {
                    owner.updateSuggestions(for: fragmentModel.strokes)
                }
            }
        }
    }
    
    public func willCheckout(args: ZTronObservation.BroadcastArgs) {
        
    }
    
    public func getOwner() -> (any ZTronObservation.Component)? {
        return self.owner
    }
    
    public func getMediator() -> (any ZTronObservation.Mediator)? {
        return self.mediator
    }
}
