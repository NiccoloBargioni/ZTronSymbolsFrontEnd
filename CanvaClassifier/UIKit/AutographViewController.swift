import UIKit
import Autograph
import SwiftUI
import ZTronObservation

public final class AutographViewController: UIViewController, Component {
    public var id: String = "Autograph ViewController"
    
    @InteractionsManaging(setupOr: .replace, detachOr: .fail) private var interactionsManager: (any MSAInteractionsManager)? = nil
    internal let mediator: MSAMediator
    
    private var hostedController: UIHostingController<DrawingFragment>
    
    public init(mediator: MSAMediator, fragmentModel: DrawingFragmentModel, suggestionsModel: SuggestionsModel) {
        self.hostedController = UIHostingController<DrawingFragment>(
            rootView: DrawingFragment(model: fragmentModel)
        )
        
        self.mediator = mediator
        super.init(nibName: nil, bundle: nil)
        self.interactionsManager = AutographViewModel(owner: self, mediator: self.mediator)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hostedController.rootView.didEndStroking = {
            // self.save()
        }
        
        self.view.addSubview(self.hostedController.view)
        
        if #available(iOS 16, *) {
            self.hostedController.sizingOptions = .intrinsicContentSize
        }
        
        self.hostedController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.hostedController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.hostedController.view.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor),
            self.hostedController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.hostedController.view.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor)
        ])
        
        self.hostedController.willMove(toParent: self)
        self.addChild(self.hostedController)
        self.hostedController.didMove(toParent: self)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.hostedController.view.invalidateIntrinsicContentSize()
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            
        } completion: { _ in
            self.hostedController.view.invalidateIntrinsicContentSize()
        }
    }
    
    public func save() {
        
        UIGraphicsBeginImageContext(self.view.bounds.size)

        if let context = UIGraphicsGetCurrentContext() {
            self.hostedController.view.layer.render(in: context)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let image = image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
    
    public func getDelegate() -> (any ZTronObservation.InteractionsManager)? {
        return self.interactionsManager
    }

    public func setDelegate(_ interactionsManager: (any ZTronObservation.InteractionsManager)?) {
        guard let manager = interactionsManager as? any MSAInteractionsManager else {
            if interactionsManager != nil {
                fatalError("Expected interactions manager of type \(String(describing: MSAInteractionsManager.self))")
            } else {
                self.interactionsManager = nil
                return
            }
        }
        
        self.interactionsManager = manager
    }

}
