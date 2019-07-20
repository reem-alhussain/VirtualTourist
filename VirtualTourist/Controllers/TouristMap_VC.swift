//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Reem on 05/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristMap_VC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteView: UIView!
    
    
    // MARK: - Variables
    var dataController:DataController!
    var pinAnnotation: MKPointAnnotation? = nil
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    // MARK: - VC Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        mapView.removeAnnotations(mapView.annotations)
        showPins()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self 
        navigationItem.rightBarButtonItem = editButtonItem
        deleteView.isHidden = true
        
        setupFetchedResultsController()
        showPins()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        deleteView.isHidden = !editing
    }
    
    
    // MARK: - Actions
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let locCoord = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = locCoord
            mapView.addAnnotation(pinAnnotation!)
            
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = locCoord
            
        } else if sender.state == .ended {
            addPin(lat: String(pinAnnotation!.coordinate.latitude), lng: String(pinAnnotation!.coordinate.longitude))
        }
    }
    
    
    // MARK: - Helpers
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        if let pins  = fetchedResultsController.fetchedObjects {
            for pin in pins where pin.latitude != nil && pin.longitude != nil {
                if pin.latitude == latitude && pin.longitude == longitude {
                    return pin
                }
            }
        }
        return nil
    }
    private func showPins() {
        if let pins = fetchedResultsController.fetchedObjects {
            for pin in pins where pin.latitude != nil && pin.longitude != nil {
                let annotation = MKPointAnnotation()
                let lat = Double(pin.latitude!)!
                let lon = Double(pin.longitude!)!
                annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
                mapView.addAnnotation(annotation)
            }
            mapView.showAnnotations(mapView.annotations, animated: true)
        }
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAlbum" {
            guard let pin = sender as? Pin else {return}
            let dest = segue.destination as! PhotoAlbum_VC
            dest.pin = pin
            dest.dataController = self.dataController
        }
    }
    
}

extension TouristMap_VC: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
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
        return pinView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {return}
        mapView.deselectAnnotation(annotation, animated: true)
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                deletePin(pin: pin)
                return
            }
            performSegue(withIdentifier: "showAlbum", sender: pin)
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showAlert(withMessage: "No link defined.")
        }
    }
    
    // MARK: - Core Data Functions
    func addPin(lat: String, lng: String) {
        let newPin = Pin(context: dataController.viewContext)
        newPin.latitude = lat
        newPin.longitude = lng
        do{
            try dataController.viewContext.save()
        }catch{
            print(error.localizedDescription)
        }
    }
    func deletePin(pin: Pin) {
        dataController.viewContext.delete(pin)
        try? dataController.viewContext.save()
    }
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
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



extension TouristMap_VC: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
}

