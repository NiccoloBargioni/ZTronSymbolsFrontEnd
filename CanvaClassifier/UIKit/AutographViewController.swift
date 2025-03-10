import UIKit
import Autograph
import SwiftUI

public final class AutographViewController: UIViewController {
        
    private var hostedController: UIHostingController<DrawingFragment> = {
        return UIHostingController<DrawingFragment>(
            rootView: DrawingFragment()
        )
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hostedController.rootView.didEndStroking = {
            self.save()
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
}
