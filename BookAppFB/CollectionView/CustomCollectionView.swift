//
//  CustomCollectionView.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import SwiftUI

class CustomCollectionView: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)

        startWigglingAllVisibleCells()
    }
    
    func startWigglingAllVisibleCells() {
        print("startWigglingAllVisibleCells")
      let cells = collectionView?.visibleCells as! [BookCell]
      
      for cell in cells {
          if isEditing { cell.startWiggling() } else { cell.stopWiggling() }
      }
    }
    
    func hideButtons() {
        for cell in collectionView.visibleCells as! [BookCell] {
            cell.button.isHidden = true
        }
    }
    
    func showButtons() {
        for cell in collectionView.visibleCells as! [BookCell] {
            cell.button.isHidden = false
        }
    }
    
    func allCellsSubviewToFront(view: UIView) {
        for cell in collectionView.visibleCells as! [BookCell] {
            cell.bringSubviewToFront(view)
        }
    }
    

    func setupCollectionView() {
        
        self.view.backgroundColor = .white
        
        collectionView.register(BookCell.self, forCellWithReuseIdentifier: "BookCell")
        
        collectionView.backgroundColor = UIColor.white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true

        collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).identifier = "cv topAnchor"
        collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).identifier = "cv bottomAnchor"
        collectionView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).identifier = "cv rightAnchor"
        collectionView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).identifier = "cv leftAnchor"
        
        collectionView.isPrefetchingEnabled = true
        
    }
}
