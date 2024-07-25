//
//  BF_Item_Shop_InAppPurchase_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit
import StoreKit

public class BF_Item_Shop_InAppPurchase_TableViewCell : BF_Item_Shop_TableViewCell {
	
	public override class var identifier: String {
		
		return "itemShopInAppPurchaseTableViewCellIdentifier"
	}
	public var inAppPurchase:(BF_Item?,SKProduct?)? {
		
		didSet {
			
			item = inAppPurchase?.0
			
			if let price = inAppPurchase?.1?.price {
				
				let numberFormatter = NumberFormatter()
				numberFormatter.locale = inAppPurchase?.1?.priceLocale
				numberFormatter.numberStyle = .currency
				
				button.title = numberFormatter.string(from: price)
				button.configuration?.imagePadding = UI.Margins/3
			}
		}
	}
}
