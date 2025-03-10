import Foundation
import ZTronObservation

public final class DrawingFragmentDelegate: MSAInteractionsManager, @unchecked Sendable {
    weak private var mediator: MSAMediator?
    weak private var owner: DrawingFragmentModel?
    
    public init(mediator: MSAMediator, owner: DrawingFragmentModel) {
        self.mediator = mediator
        self.owner = owner
    }
    
    public func peerDiscovered(eventArgs: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let drawingPage = eventArgs.getSource() as? DrawingPageModel {
            self.mediator?.signalInterest(owner, to: drawingPage)
        }
    }
    
    public func peerDidAttach(eventArgs: ZTronObservation.BroadcastArgs) { }
    
    public func notify(args: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let drawingPage = args.getSource() as? DrawingPageModel {
            switch drawingPage.lastAction {
            case .clear:
                owner.clear()
                
            case .undoLast:
                owner.undoLastStroke()
                
            default:
                break
            }
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
