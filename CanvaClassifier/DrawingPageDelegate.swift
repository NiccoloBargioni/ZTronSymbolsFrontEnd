import Foundation
import ZTronObservation

public final class DrawingPageDelegate: MSAInteractionsManager, @unchecked Sendable {
    weak private var mediator: MSAMediator?
    weak private var owner: DrawingPageModel?
    
    public init(mediator: MSAMediator, owner: DrawingPageModel) {
        self.mediator = mediator
        self.owner = owner
    }
    
    public func peerDiscovered(eventArgs: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let fragment = eventArgs.getSource() as? DrawingFragmentModel {
            self.mediator?.signalInterest(owner, to: fragment)
        }
    }
    
    public func peerDidAttach(eventArgs: ZTronObservation.BroadcastArgs) { }
    
    public func notify(args: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let fragment = args.getSource() as? DrawingFragmentModel {
            owner.isUndoButtonDisabled = fragment.strokes.count <= 0
        }
    }
    
    public func willCheckout(args: ZTronObservation.BroadcastArgs) {  }
    
    public func getOwner() -> (any ZTronObservation.Component)? {
        return self.owner
    }
    
    public func getMediator() -> (any ZTronObservation.Mediator)? {
        return self.mediator
    }
}
