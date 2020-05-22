//
//  CollectionView.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI
import CoreData

var count : Int = 0

struct CollectionView: UIViewControllerRepresentable {
    
    @EnvironmentObject var library : BookData
    
    var didSelectItem : () -> ()
   
    class Coordinator: NSObject, UICollectionViewDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
        
        var parent : CollectionView
        
        var container: NSPersistentContainer!
        var fetchedResultsController: NSFetchedResultsController<CoreBook>!
        var commitPredicate: NSPredicate?
        
        var cvc: CustomCollectionView!
        var moveIndexPath: IndexPath?
        var longPressGestureRecognizer: UILongPressGestureRecognizer!
        
        private var currentOffset: CGPoint = CGPoint(x: 0, y: 0)
        
        init(_ parent: CollectionView) {
            self.parent = parent
            
            self.container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let layout = CustomFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: 111, height: 171)
            layout.estimatedItemSize = CGSize(width: 111, height: 171)
            layout.minimumLineSpacing = 25
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 9)
            cvc = CustomCollectionView(collectionViewLayout: layout)
            super.init()
            longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
            longPressGestureRecognizer.minimumPressDuration = 0.3
            cvc.collectionView.addGestureRecognizer(longPressGestureRecognizer)
            cvc.collectionView.delegate = self
            cvc.collectionView.dataSource = self
       
            cvc.collectionView.reorderingCadence = .fast
            
            loadSavedData()
        }
        
        func loadSavedData() {
            // setup
            let sortDescriptors = parent.library.sortDescriptors
            
            if fetchedResultsController == nil {
                let fetchRequest = NSFetchRequest<CoreBook>(entityName: "CoreBook")
                
                fetchRequest.sortDescriptors = sortDescriptors
                fetchRequest.fetchBatchSize = 20
                
                fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController.delegate = self
            }
                //fetchedResultsController.fetchRequest.predicate = commitPredicate
                
            fetchedResultsController.fetchRequest.sortDescriptors = sortDescriptors
        
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Error: could not performFetch: \(error.localizedDescription)")
            }
        }
        
        func saveContext() {
            if container.viewContext.hasChanges {
                do {
                    try container.viewContext.save()
                } catch {
                    print("An error occurred while saving: \(error)")
                }
            }
        }
        
        func movedCell() -> BookCell? {
            guard let indexPath = moveIndexPath else {
                return nil
            }
            
            return cvc.collectionView.cellForItem(at: indexPath) as? BookCell
        }
        
        func animatePickingUpCell(cell: BookCell?) {
          UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 0.7
          }, completion: nil)
        }
        
        func animatePuttingDownCell(cell: BookCell?) {
          UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .beginFromCurrentState], animations: { () -> Void in
            cell?.alpha = 1.0
          }, completion: { finished in
            cell?.startWiggling()
          })
        }
        
        @objc func longPress(_ gesture: UILongPressGestureRecognizer) {
            if !cvc.isEditing {
                return
            }
            let location = gesture.location(in: cvc.collectionView)
            moveIndexPath = cvc.collectionView.indexPathForItem(at: location) // pretty cool
            switch (gesture.state) {
            case .began:
                guard let indexPath = moveIndexPath else {
                    return
                }
                
                cvc.setEditing(true, animated: true)
                cvc.collectionView.beginInteractiveMovementForItem(at: indexPath)
                movedCell()?.startWiggling()
                animatePickingUpCell(cell: movedCell())
            case .changed:
                cvc.collectionView.updateInteractiveMovementTargetPosition(location)
            case .ended:
                cvc.collectionView.endInteractiveMovement()
                animatePuttingDownCell(cell: movedCell())
                moveIndexPath = nil
            default:
                cvc.collectionView.cancelInteractiveMovement()
                moveIndexPath = nil
            }
        }
        
        
// MARK -- fetched results controller
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .delete:
                if let indexPath = indexPath {
                    cvc.collectionView.deleteItems(at: [indexPath])
                } else {
                    print("Error: could not delete item")
                }
            default: return
            }
        }
// MARK -- CollectionView Delegates
        func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
            true
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.1) {
                    cell.alpha = 0.8
                    cell.transform = .init(scaleX: 0.95, y: 0.95)
                }
                
                UIView.animate(withDuration: 0.3) {
                    cell.alpha = 1.0
                    cell.transform = .identity
                }
            }
            // create temporary placeholder book for detail page to avoid deletion issues
            parent.library.contextBook = FullBook(fromCoreBook: fetchedResultsController.object(at: indexPath))
            
            parent.didSelectItem()
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //return books.count
            let sectionInfo = fetchedResultsController.sections![section]
//            print(sectionInfo.numberOfObjects)
            return sectionInfo.numberOfObjects
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as? BookCell else {
                fatalError("fatalError: Could not load cell")
            }
            
            let image = FullBook(fromCoreBook: fetchedResultsController.object(at: indexPath)).getImage()
            let title = fetchedResultsController.object(at: indexPath).title ?? ""
            cell.configure(image: image, title: title)
            cell.button.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        
            if cvc.isEditing {
                cell.startWiggling()
            } else {
                cell.stopWiggling()
            }
            
            if indexPath.item == moveIndexPath?.item {
                cell.alpha = 0.7
            } else {
                cell.alpha = 1.0
            }
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            reorderItems(collectionView: collectionView, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        }
        

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if cvc.isEditing == true {
                if parent.library.editMode == true {
                    let cell = cell as! BookCell
                    cell.startWiggling()
                    cell.button.isHidden = false
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if cvc.isEditing == true {
                if parent.library.editMode == true {
                    let cell = cell as! BookCell
                    cell.stopWiggling()
                    cell.button.isHidden = true
                }
            }
        }
// MARk -- helper functions
        private func reorderItems(collectionView: UICollectionView, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
            if let books = fetchedResultsController.fetchedObjects {
                collectionView.performBatchUpdates ({

                    cvc.collectionView.forLastBaselineLayout.layer.speed = 0.6
                    
                    if sourceIndexPath.item < destinationIndexPath.item {
                        for i in books {
                            if i.layout > sourceIndexPath.item && i.layout <= destinationIndexPath.item {
                                i.setValue(i.layout - 1, forKey: "layout")
                            }
                        }
                    } else {
                        for i in books {
                            if i.layout < sourceIndexPath.item && i.layout >= destinationIndexPath.item {
                                i.setValue(i.layout + 1, forKey: "layout")
                            }
                        }
                    }

                    // set moved item to destination layout
                    books[sourceIndexPath.item].setValue(Int16(destinationIndexPath.item), forKey: "layout")

                    loadSavedData()
                    
                }, completion: { finished in
                    if finished == true {
                        self.cvc.collectionView.forLastBaselineLayout.layer.speed = 1.0
                    }
                })
            }
        }
        
        func refreshEdit(editMode: Bool) {
            if editMode {
                // prevents circular dependency and redundant batch updates
                if parent.library.sortDescriptors[0].key != "layout" {
                    // sort by layout
                    parent.library.sortDescriptors = [NSSortDescriptor(key: "layout", ascending: true)]
                    self.cvc.collectionView.performBatchUpdates({
                        // refresh fetch request
                        loadSavedData()
                        
                    }, completion: { finished in
                        if finished {
                            self.cvc.collectionView.reloadSections(IndexSet(integersIn: 0...0)) // required for animation for some reason
                            // show all edit buttons for visible cells
                            self.cvc.showButtons()
                            // wiggle
                            self.cvc.setEditing(true, animated: true)
                        }
                    })
                } else {
                    // show buttons
                    self.cvc.showButtons()
                    // wiggle
                    self.cvc.setEditing(true, animated: true)
                }
            } else {
                // prevents unnecessary execution
                if self.cvc.isEditing {
                    // hide buttons
                    self.cvc.hideButtons()
                    // turn off wiggle
                    self.cvc.setEditing(false, animated: true)
                }
            }
        }
        
        func refreshSort() {
            self.cvc.collectionView.performBatchUpdates({
                loadSavedData()
            }, completion: { finished in
                if finished {
                    self.cvc.collectionView.reloadSections(IndexSet(integersIn: 0...0))
                }
            })
        }
        
        /* FIX collectionview with one cell holds cell at index 1 for some reason?? It started doing it a little while ago but didn't always do it*/
        @objc func deleteItem(_ sender: UIButton) {
            if let cell = sender.superview?.superview as? BookCell {
                guard let index = fetchedResultsController.fetchedObjects!.firstIndex(where: { $0.title == cell.title }) else {
                    print("Error: Book not found")
                    return
                }
                let book = fetchedResultsController.object(at: IndexPath(row: index, section: 0))
                //print("deleting title \(book.title!) with added \(book.added) and layout \(book.layout)")
                if let books = fetchedResultsController.fetchedObjects {

                    // I think there's a bug here
                    for i in books {
                        if i.added < book.added {
                            i.setValue(i.added - 1, forKey: "added")
                            //print("decreased added for title \(i.title!) from \(i.added + 1) to \(i.added)")
                        }
                        if i.layout > book.layout {
                            i.setValue(i.layout - 1, forKey: "layout")
                            //print("decreased layout for title \(i.title!) from \(i.layout + 1) to \(i.layout)")
                        }
                    }
                    
                    fetchedResultsController.managedObjectContext.delete(book)
                    
                    saveContext()
                    
                    loadSavedData()
                } else {
                    print("Error: book not in fetched results")
                }
            } else {
                print("Error: Could not cast")
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UICollectionViewController {
        return context.coordinator.cvc
    }
    
    func updateUIViewController(_ uiViewController: UICollectionViewController, context: Context) {
        
        if library.didSort == true {
            context.coordinator.refreshSort()
            library.didSort = false
        }
        
        context.coordinator.refreshEdit(editMode: library.editMode)
        
    }
}

// allows popping off the view stack (swiping from detailview back to library)
extension UINavigationController : UIGestureRecognizerDelegate{
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
