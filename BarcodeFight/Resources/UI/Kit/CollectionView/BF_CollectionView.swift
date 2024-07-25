//
//  BF_CollectionView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 18/08/2023.
//

import Foundation
import UIKit

public class BF_CollectionView : UICollectionView {
	
	public var isHeightDynamic:Bool = false {
		
		didSet {
			
			isScrollEnabled = !isHeightDynamic
		}
	}
	public override var contentSize: CGSize {
		
		didSet {
			
			if isHeightDynamic {
				
				self.invalidateIntrinsicContentSize()
			}
		}
	}
	public override var intrinsicContentSize: CGSize {
		
		if isHeightDynamic {
			
			return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
		}
		
		return super.intrinsicContentSize
	}
	
	public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		
		super.init(frame: frame, collectionViewLayout: layout)
		
		backgroundColor = .clear
		register(BF_CollectionViewCell.self, forCellWithReuseIdentifier: BF_CollectionViewCell.identifier)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
