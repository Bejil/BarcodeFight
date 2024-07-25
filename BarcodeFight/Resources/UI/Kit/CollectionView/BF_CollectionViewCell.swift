//
//  BF_CollectionViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/06/2023.
//

import Foundation
import UIKit

public class BF_CollectionViewCell : UICollectionViewCell {
	
	public class var identifier: String {
		
		return "collectionViewCellIdentifier"
	}
	
	public override var isHighlighted: Bool {
		
		didSet {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
				
				self.transform = self.isHighlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
				
			}, completion: nil)
		}
	}
}
