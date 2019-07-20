//
//  PhotoAlbum_VC+UICollectionView.swift
//  VirtualTourist
//
//  Created by Reem on 07/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation
import UIKit

extension PhotoAlbum_VC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoVC
        cell.imageView.image = nil
        cell.activityIndicator.start()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoVC = cell as! PhotoVC
        photoVC.imageUrl = photo.url!
        updateImage(using: photoVC, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.url {
            FlickerClient.shared().stopDownloading(imageUrl)
        }
    }
    
    private func updateImage(using cell: PhotoVC, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
            cell.activityIndicator.stop()
        } else {
            if let imageUrl = photo.url {
                cell.activityIndicator.start()
                FlickerClient.shared().downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        DispatchQueue.main.async {
                            cell.activityIndicator.stop()
                        }
                        return
                    } else if let data = data {
                        DispatchQueue.main.async {
                            if let currentCell = collectionView.cellForItem(at: index) as? PhotoVC {
                                if currentCell.imageUrl == imageUrl {
                                    currentCell.imageView.image = UIImage(data: data)
                                    cell.activityIndicator.stop()
                                }
                            }
                            photo.image = data
                             try? self.dataController.viewContext.save()
                         }
                    }
                }
            }
        }
    }
    
    
}



