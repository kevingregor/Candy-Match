//
//  Card.swift
//  Candy Match
//
//  Created by Kevin Gregor on 1/7/17.
//  Copyright © 2017 Kevin Gregor. All rights reserved.
//

import UIKit

class Card: UIView {
    private var candy : String!
    
    let backImageView = UIImageView()
    let frontImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Add image view into view
        addSubview(backImageView)
        
        // Initialize the imageview with an image
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        backImageView.image = UIImage(named: "back")
        applyPositionConstraints(imageView: backImageView)
        
        // Add front image view into view
        addSubview(frontImageView)
        
        frontImageView.translatesAutoresizingMaskIntoConstraints = false
        applyPositionConstraints(imageView: frontImageView)
    }
    
    func applyPositionConstraints(imageView:UIImageView) {
        
        let topConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        
        let leftConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        
        let rightConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        
        let botConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        addConstraints([topConstraint, leftConstraint, rightConstraint, botConstraint])
    }
    
    func flipUp() {
        
        // Run the transition animation
        UIView.transition(from: backImageView, to: frontImageView, duration: 0.5, options: .transitionFlipFromLeft, completion: nil)
        
        applyPositionConstraints(imageView: frontImageView)
    }
    
    func flipDown() {
        
        // Run the transition animation
        UIView.transition(from: frontImageView, to: backImageView, duration: 0.5, options: .transitionFlipFromRight, completion: nil)
        
        applyPositionConstraints(imageView: backImageView)
    }
    
    public func setCandy(candy: String) {
        self.candy = candy
        frontImageView.image = UIImage(named: candy)
    }

    public func getCandy() -> String{
        return self.candy
    }
    
}
