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
   
    class Coordinator: NSObject, UICollectionViewDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate, NSFetchedResultsControllerDelegate {
        
        var parent : CollectionView
        
        var container: NSPersistentContainer!
        var fetchedResultsController: NSFetchedResultsController<CoreBook>!
        var commitPredicate: NSPredicate?
        
        var cvc: CustomCollectionView!
        
        private var currentOffset: CGPoint = CGPoint(x: 0, y: 0)
        
        init(_ parent: CollectionView) {
            self.parent = parent
            
            self.container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: 111, height: 171)
            layout.estimatedItemSize = CGSize(width: 111, height: 171)
            layout.minimumLineSpacing = 25
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 9)
            cvc = CustomCollectionView(collectionViewLayout: layout)
            super.init()
            cvc.collectionView.delegate = self
            cvc.collectionView.dataSource = self
            cvc.collectionView.dragDelegate = self
            cvc.collectionView.dropDelegate = self
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
        // does not appear to work
//
//        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//            if parent.library.editMode == true {
//                if let cell = collectionView.cellForItem(at: indexPath) as? BookCell {
//                    cell.button.isHidden = false
//                }
//            }
//        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //return books.count
            let sectionInfo = fetchedResultsController.sections![section]
            print(sectionInfo.numberOfObjects)
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
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
            return true
        }

        func collectionView(_ collectionView: UICollectionView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
            return true
        }
        
        func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            print("itemsForBeginning session")
            let cell = collectionView.cellForItem(at: indexPath) as! BookCell
            //cell.button.isHidden = true
            //cell.stopWiggling()
            let object = fetchedResultsController.object(at: indexPath)
            let itemProvider = NSItemProvider(object: "\(indexPath)" as NSString) // ?? not sure about the index path thing
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = object
            dragItem.previewProvider = {
                let view = cell.image!
                return UIDragPreview(view: view)
            }
            session.localContext = cell
            return [dragItem]
        }
    
        func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
            print("dragPreviewParametersForItemAt \(indexPath.item)")
            let cell = collectionView.cellForItem(at: indexPath) as! BookCell
            cell.button.isHidden = true
            let previewParameters = UIDragPreviewParameters()
            previewParameters.visiblePath = UIBezierPath(roundedRect: cell.image.frame, cornerRadius: 5)
            previewParameters.backgroundColor = .clear
            return previewParameters
        }
    
        
        func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
            if let cell = session.localContext as? BookCell {
                print("dragSessionDidEnd")
                cell.button.isHidden = false
                cell.startWiggling()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
            print("performDropWith")
            let destinationIndexPath: IndexPath
            if let indexPath = coordinator.destinationIndexPath {
                destinationIndexPath = indexPath
            } else {
                destinationIndexPath = IndexPath(row: fetchedResultsController.sections![0].numberOfObjects, section: 0)
            }
            
            switch coordinator.proposal.operation {
                case .move:
                    reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
                    print("case .move")
                default: return
            }
            
        }
        
        func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
            if collectionView.hasActiveDrag, let _ = destinationIndexPath {
                return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            } else {
                return UICollectionViewDropProposal(operation: .forbidden)
            }
        }

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if cvc.collectionView.isDragging == true {
                if parent.library.editMode == true {
                    let cell = cell as! BookCell
                    cell.startWiggling()
                    cell.button.isHidden = false
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            if cvc.collectionView.isDragging == true {
                if parent.library.editMode == true {
                    let cell = cell as! BookCell
                    cell.stopWiggling()
                    cell.button.isHidden = true
                }
            }
        }
// MARk -- helper functions
        private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
            let items = coordinator.items
            if  items.count == 1, let item = items.first,
                let sourceIndexPath = item.sourceIndexPath,
                let _ = item.dragItem.localObject as? CoreBook,
                let books = fetchedResultsController.fetchedObjects {
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
                    
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }, completion: { finished in
                    if finished == true {
                        self.cvc.collectionView.forLastBaselineLayout.layer.speed = 1.0
                    }
                })
                
                saveContext()
            }
        }
        
        func refreshEdit(editMode: Bool) {
            if editMode {
                // prevents circular dependency and redundant batch updates
                if parent.library.sortDescriptors[0].key != "layout" {
                    // sort by layout
                    parent.library.sortDescriptors = [NSSortDescriptor(key: "layout", ascending: true)]
                    // refresh fetch request
                    loadSavedData()
                    // disable scroll and enable dragInteraction
                    //self.cvc.collectionView.isScrollEnabled = false
                    self.cvc.collectionView.dragInteractionEnabled = true
                    // show all edit buttons for visible cells
                    self.cvc.showButtons()
                    // animate changes
//                    self.cvc.collectionView.performBatchUpdates({
//                        cvc.collectionView.forLastBaselineLayout.layer.speed = 0.9
//                        self.cvc.collectionView.reloadSections(IndexSet(integersIn: 0...0))
//                    }, completion: { finished in
//                        if finished {
//                            self.cvc.collectionView.forLastBaselineLayout.layer.speed = 1.0
//                        }
//                })
                    // wiggle
                    self.cvc.setEditing(true, animated: true)
                    self.cvc.collectionView.reloadData()
                    
                } else {
                    // always show buttons and prepare for drag/drop, but in this case, make it instantaneous
                    self.cvc.showButtons()
                    // enable drag interaction
                    self.cvc.collectionView.dragInteractionEnabled = true
                    // wiggle
                    self.cvc.setEditing(true, animated: true)
                }
            } else {
                // prevents unnecessary execution
                if self.cvc.collectionView.dragInteractionEnabled == true {
                    //self.cvc.collectionView.isScrollEnabled = true
                    self.cvc.collectionView.dragInteractionEnabled = false
                    // hide buttons
                    self.cvc.hideButtons()
                    // turn off wiggle
                    self.cvc.setEditing(false, animated: true)
                    // reload data
                    self.cvc.collectionView.reloadData()
                }
            }
        }
        
        func refreshSort() {
            loadSavedData()
            self.cvc.collectionView.reloadData()
        }
        
        @objc func deleteItem(_ sender: UIButton) {
            if let cell = sender.superview as? BookCell {
                let cv = cell.superview as! UICollectionView
                if cv.hasActiveDrag || cv.hasActiveDrop {
                    return
                }
                if let index = fetchedResultsController.fetchedObjects!.firstIndex(where: { $0.title! == cell.title }) {
                    //let book = books[indexPath]
                    let book = fetchedResultsController.object(at: IndexPath(row: index, section: 0))
                    print("deleting title \(book.title!) with added \(book.added) and layout \(book.layout)")
                    if let books = fetchedResultsController.fetchedObjects {

                        for i in books {
                            if i.added < book.added {
                                i.setValue(i.added + 1, forKey: "added")
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
                    }
                } else {
                    print("Error: Cell \(cell.title!) not found")
                    return
                }
            } else {
                print("Error: deleteItem: cast failed")
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
