//
//  BookCellCollectionViewCell.swift
//  SwiftUIBook
//
//  Created by Kyle Burns on 5/3/20.
//  Copyright © 2020 Kyle Burns. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
    
    var image : UIImageView!
    
    var button : UIButton!
    
    var title : String!
    
    func configure(image: UIImage, title: String) {
        self.image.image = image
        self.title = title
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImageView(frame: CGRect(x: 0, y: 11, width: 100, height: 160))
        //self.image.translatesAutoresizingMaskIntoConstraints = false
        self.image.contentMode = .scaleAspectFill
        self.image.layer.cornerRadius = 5
        self.image.clipsToBounds = true
        
        self.layer.cornerRadius = 5
        self.layer.shadowPath = UIBezierPath(roundedRect: self.image.bounds, cornerRadius: 5).cgPath
        buttonShadow(view: self, radius: 5, color: UIColor.darkGray.cgColor, opacity: 0.9, offset: CGSize(width: 0, height: 16))
        
        self.button = UIButton(type: .custom)
        self.button.frame = CGRect(x: 89, y: 0, width: 22, height: 22)
        self.button.layer.cornerRadius = 0.5 * self.button.bounds.size.width
        //self.button.layer.opacity = 0.8
        self.button.clipsToBounds = true
        self.button.contentVerticalAlignment = .fill
        self.button.contentHorizontalAlignment = .fill
        self.button.imageEdgeInsets = UIEdgeInsets(top: -2, left: -2, bottom: -2, right: -2)
        self.button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        self.button.imageView?.tintColor = .darkGray
        self.button.imageView?.clipsToBounds = true
        self.button.layer.backgroundColor = UIColor.darkWhite.cgColor
        self.button.isHidden = true
        //print("selfForItemAt: \(indexPath)")
        self.backgroundColor = .clear
        
        self.contentView.addSubview(image)
        self.contentView.addSubview(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }

        let angle = 0.02

        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggle.values = [-angle, angle]

        wiggle.autoreverses = true
        wiggle.duration = randomInterval(interval: 0.1, variance: 0.025)
        wiggle.repeatCount = Float.infinity

        contentView.layer.add(wiggle, forKey: "wiggle")

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [2.0, 0.0]

        bounce.autoreverses = true
        bounce.duration = randomInterval(interval: 0.1, variance: 0.025)
        bounce.repeatCount = Float.infinity

        contentView.layer.add(bounce, forKey: "bounce")
    }
    
    func randomInterval(interval: TimeInterval, variance: Double) -> TimeInterval {
      return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
    }
    
    func stopWiggling() {
        contentView.layer.removeAllAnimations()
    }
    
//    override func prepareForReuse() {
//      super.prepareForReuse()
//
//      stopWiggling()
//    }
    
    // utility
    func buttonShadow(view: UIView, radius: CGFloat, color: CGColor?, opacity: Float = 1.0, offset: CGSize = .zero) {
         view.layer.shadowRadius = radius
         view.layer.shadowColor = color
         view.layer.shadowOffset = offset
         view.layer.shadowOpacity = opacity
    }
}
