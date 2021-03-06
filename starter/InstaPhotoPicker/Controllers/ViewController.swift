//
//  ViewController.swift
//  InstaPhotoPicker
//
//  Created by Osaretin Uyigue on 6/28/22.
//

import UIKit
import Photos
import PhotosUI
class ViewController: UIViewController {

    
    //MARK: - View's LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setUpViews()
        setUpGestureRecognizers()
        fetchPhotoLibraryAssets()
    }
    
   
    deinit {
        
    }
    

    
    //MARK: - Properties
    // ADD PROPERTIES CODE HERE
   
    
    fileprivate let zoomNavigationDelegate = ZoomTransitionDelegate()
    fileprivate weak var selectedImageView: UIImageView?


    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate var mediaPickerViewTopAnchor = NSLayoutConstraint()
    fileprivate let collapsedModePadding = UIScreen.main.bounds.height

    fileprivate lazy var mediaPickerView: MediaPickerView = {
        let mediaPickerView = MediaPickerView()
        mediaPickerView.delegate = self
        return mediaPickerView
    }()
    
    
    fileprivate lazy var askPhotoPermissionView: AskPhotoPermissionView = {
        let view = AskPhotoPermissionView()
        view.delegate = self
        return view
    }()
    
    
    
    //MARK: - Methods
    fileprivate func setUpViews() {
        view.addSubview(mediaPickerView)
        view.addSubview(askPhotoPermissionView)
        
        mediaPickerViewTopAnchor = mediaPickerView.topAnchor.constraint(equalTo: view.topAnchor, constant: collapsedModePadding)
        mediaPickerViewTopAnchor.isActive = true
        
        mediaPickerView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, size: .init(width: 0, height: view.frame.height))
        
        askPhotoPermissionView.anchor(top: nil, leading: view.leadingAnchor, bottom: mediaPickerView.topAnchor, trailing: view.trailingAnchor, size: .init(width: 0, height: view.frame.height))

    }
    
    
    fileprivate func setUpGestureRecognizers() {
        let swipeGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    
    
    //MARK: - Photokit
   
    fileprivate func getPhotoPermission(completionHandler: @escaping(Bool) -> Void) {
        // REPLACE CODE IN HERE
        completionHandler(true)
    }
    
    
    

    
    
    fileprivate func fetchPhotoLibraryAssets() {
        
        // ADD CODE IN HERE

    }
    

    
   
    
    
    
    
    
    
    
    //MARK: - Target Selectors
    @objc fileprivate func panGestureRecognizerAction(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        
        switch gesture.state {
        case .changed:
            
            let translatedYPoint = translation.y
            
            if mediaPickerViewTopAnchor.constant < 0 {
                mediaPickerViewTopAnchor.constant = 0 // Prevents user from dragging mediaPickerView past 0
            } else {
                mediaPickerViewTopAnchor.constant += translatedYPoint // Allows user to drag
            }
            
            gesture.setTranslation(.zero, in: view)

        case .failed, .cancelled, .ended:
            
           onGestureCompletion(gesture: gesture)
         default:
            break
        }
        
    }
    
    
    // Set mediaPickerView back to open or collapsed position 
    fileprivate func onGestureCompletion(gesture: UIPanGestureRecognizer) {
        let yTranslation: CGFloat = gesture.direction(in: view) == .Down ? collapsedModePadding : 0
        
        mediaPickerViewTopAnchor.constant = yTranslation
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: .curveEaseIn) {[weak self] in
            self?.view.layoutIfNeeded()
        }
    }
        
    
    
    
}




//MARK: - AskPhotoPermissionViewDelegate
extension ViewController: AskPhotoPermissionViewDelegate {
    
    func handleAskForPhotoPermission() {
        // On button tap, we ask for auth to access photos library and if granted we fetchPhotos
        getPhotoPermission { [weak self] granted  in
            if granted {
                self?.fetchPhotoLibraryAssets()
            }
        }
    }
}




//MARK: - MediaPickerViewDelegate & AlbumVCDelegate & PHPickerViewControllerDelegate
extension ViewController: MediaPickerViewDelegate, AlbumVCDelegate, PHPickerViewControllerDelegate {
    
    //MARK: - MediaPickerViewDelegate
    
    func handleOpenAlbumVC() {
        // REPLACE THE CODE IN THIS METHOD
        let albumVC = AlbumVC()
       albumVC.modalPresentationStyle = .custom
       albumVC.transitioningDelegate = self
       albumVC.delegate = self
       present(albumVC, animated: true, completion: nil)
    }
    
    func handleTransitionToStoriesEditorVC(with selectedImageView: UIImageView) {
        self.selectedImageView = selectedImageView
        navigationController?.delegate = zoomNavigationDelegate
        let storiesEditorVC = StoriesEditorVC(selectedImage: selectedImageView.image ?? UIImage())
       navigationController?.pushViewController(storiesEditorVC, animated: true)
    }
    
    
    func handleBeyondTutScope() {
        UIAlertController.show("Beyond the scope of this tutorial", from: self)
    }
    
    
    
    //MARK: - AlbumVCDelegate
    func handleDidSelect(album: PHAssetCollection) {
        // ADD CODE IN HERE
    }
    
    
    func handleOnDismiss() {
        mediaPickerView.handleAnimateArrow(toIdentity: true)
    }
    
    
    func handlePresentPHPickerViewController() {
        // ADD CODE IN HERE
    }
    
    
    
    //MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // ADD CODE IN HERE
    }
    
    
}


//MARK: - ZoomViewController Transition Delegates
extension ViewController: ZoomViewController {
    
    func zoomingImageView(for transition: ZoomTransitionDelegate) -> UIImageView? {
        
        if let selectedImageView = selectedImageView {
            return selectedImageView
        } else {
            return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
        }
        
    }
    
    func zoomingBackgroundView(for transition: ZoomTransitionDelegate) -> UIView? {
        return nil
    }

    
}





//MARK: - Presentation Animation for StoriesEditorVC
extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        let height = view.frame.height / 2
        presentationController.cardHeight = height
        return presentationController
    }
}





//MARK: - PHPhotoLibraryChangeObserver

