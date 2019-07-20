//
//  PhotoAlbum_VC.swift
//  VirtualTourist
//
//  Created by Reem on 05/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbum_VC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newCollectionBtn: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: - Variables
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin?
    var totalPagesNum: Int? = nil
    var selectedIndx = [IndexPath]()
    var insertedIndx: [IndexPath]!
    var deletedIndx: [IndexPath]!
    var updatedIndx: [IndexPath]!
    
    
    // MARK: - VC Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        updateFlowLayout(view.frame.size)
        activityIndicator.stop()
        updateStatusLabel("")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        guard let pin = pin else {return}
        showOnTheMap(pin)
        setupFetchedResultsController()
        
        if let photos = fetchedResultsController.fetchedObjects, photos.count == 0 {
            fetchPhotosFromAPI()
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    // MARK: - Actions
    @IBAction func updateNewCollection(_ sender: Any) {
        
        for photos in fetchedResultsController.fetchedObjects! {
            dataController.viewContext.delete(photos)
        }
        try? dataController.viewContext.save()
        fetchPhotosFromAPI()
    }
    
    
    // MARK: - Helpers
    private func fetchPhotosFromAPI() {
        
        self.newCollectionBtn.isEnabled = false
        activityIndicator.start()
        self.updateStatusLabel("Fetching photos ...")
        
        FlickerClient.shared().searchBy(latitude: Double(pin!.latitude!)!, longitude: Double(pin!.longitude!)!, totalPages: totalPagesNum) { (photosResponse, error) in
            DispatchQueue.main.async {
                self.activityIndicator.stop()
                self.newCollectionBtn.isEnabled = true
            }
            if let photosResponse = photosResponse {
                self.totalPagesNum = photosResponse.photos.pages
                let totalPhotos = photosResponse.photos.photo.count
                
                if totalPhotos == 0 {
                    self.updateStatusLabel("There is no photo in this location.")
                }else{
                    self.updateStatusLabel("")
                    self.addPhotos(photos: photosResponse)
                }
            } else if let error = error {
                print(error.localizedDescription)
                self.showAlert(withTitle: "Error", withMessage: error.localizedDescription)
                self.updateStatusLabel("Something went wrong, please try again.")
            }
        }
    }
    private func updateStatusLabel(_ text: String) {
        DispatchQueue.main.async {
            self.label.text = text
        }
    }
    
    
    // MARK: - UI
    private func updateFlowLayout(_ withSize: CGSize) {
        
        let landscape = withSize.width > withSize.height
        
        let space: CGFloat = landscape ? 5 : 3
        let items: CGFloat = landscape ? 2 : 3
        
        let dimension = (withSize.width - ((items + 1) * space)) / items
        
        collectionViewFlowLayout?.minimumInteritemSpacing = space
        collectionViewFlowLayout?.minimumLineSpacing = space
        collectionViewFlowLayout?.itemSize = CGSize(width: dimension, height: dimension)
        collectionViewFlowLayout?.sectionInset = UIEdgeInsets(top: space, left: space, bottom: space, right: space)
    }
    
    
    // MARK: - Core Data Functions
    func addPhotos(photos: PhotosResponse) {
        do{
            for photo in photos.photos.photo {
                let pho = Photo(context: dataController.viewContext)
                pho.image = nil
                pho.title = photo.title
                pho.url = photo.url
                pho.pin = pin
            }
            try dataController.viewContext.save()
        }catch{
            print(error)
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    func deletePhoto(at indexPath: IndexPath) {
        
        dataController.viewContext.delete(fetchedResultsController.object(at: indexPath))
        try? dataController.viewContext.save()
    }
    fileprivate func setupFetchedResultsController() {
        
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin!])
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}


// MARK: - MKMapViewDelegate
extension PhotoAlbum_VC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        print(annotation)
        return pinView
    }
    private func showOnTheMap(_ pin: Pin) {
        
        let locCoord = CLLocationCoordinate2D(latitude: Double(pin.latitude!)!, longitude: Double(pin.longitude!)!)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
}
