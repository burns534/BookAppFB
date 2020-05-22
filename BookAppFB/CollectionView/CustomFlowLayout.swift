//
//  CustomFlowLayout.swift
//  BookAppFB
//
//  Created by Kyle Burns on 5/21/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class CustomFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath as IndexPath, withTargetPosition: position)
        
        attributes.alpha = 0.7
        
        return attributes
    }
}
