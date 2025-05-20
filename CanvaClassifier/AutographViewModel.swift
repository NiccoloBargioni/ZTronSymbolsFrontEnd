import Foundation
import ZTronObservation

public class AutographViewModel: MSAInteractionsManager, @unchecked Sendable {
    weak private var mediator: MSAMediator? = nil
    weak private var owner: AutographViewController? = nil
    
    public init(owner: AutographViewController, mediator: MSAMediator) {
        self.owner = owner
        self.mediator = mediator
    }
    
    public func peerDiscovered(eventArgs: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let drawingPage = eventArgs.getSource() as? DrawingPageModel {
            self.mediator?.signalInterest(owner, to: drawingPage)
        }
    }
    
    public func peerDidAttach(eventArgs: ZTronObservation.BroadcastArgs) {
        
    }
    
    public func notify(args: ZTronObservation.BroadcastArgs) {
        guard let owner = self.owner else { return }
        
        if let drawingPage = args.getSource() as? DrawingPageModel {
            if drawingPage.lastAction == .save {
                owner.save()
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
