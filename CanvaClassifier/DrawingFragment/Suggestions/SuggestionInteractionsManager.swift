import Foundation
import ZTronObservation

public final class SuggestionInteractionsManager: MSAInteractionsManager, @unchecked Sendable {
    weak private var owner: (any AnySuggestionModel)?
    weak private var mediator: MSAMediator?
    
    public init(owner: any AnySuggestionModel, mediator: MSAMediator) {
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
        if let fragmentModel = args.getSource() as? DrawingFragmentModel {
            self.updateIfNeeded(from: fragmentModel)
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
    
    private final func updateIfNeeded(from fragmentModel: DrawingFragmentModel) -> Void {
        guard let owner = self.owner else { return }
        guard fragmentModel.lastAction != .ready else { return }
        
        let shouldUpdate = fragmentModel.strokes.reduce(true) { shouldUpdate, nextStroke in
            return shouldUpdate && nextStroke.count > 1
        }
        
        if shouldUpdate {
            Task(priority: .medium) {
                owner.updateSuggestions(for: fragmentModel.strokes) {
                    guard fragmentModel.lastAction == .strokingEnded else { return }
                    owner.onStrokeEnded()
                }
            }
        }
    }
}
