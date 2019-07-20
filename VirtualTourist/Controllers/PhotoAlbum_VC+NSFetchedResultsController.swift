//
//  PhotoAlbum_VC+NSFetchedResultsController.swift
//  VirtualTourist
//
//  Created by Reem on 07/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation
import CoreData

extension PhotoAlbum_VC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndx = [IndexPath]()
        deletedIndx = [IndexPath]()
        updatedIndx = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            insertedIndx.append(newIndexPath!)
            break
        case .delete:
            deletedIndx.append(indexPath!)
            break
        case .update:
            updatedIndx.append(indexPath!)
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in 
            for indexPath in self.insertedIndx {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deletedIndx {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updatedIndx {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
    }
    
    
}
