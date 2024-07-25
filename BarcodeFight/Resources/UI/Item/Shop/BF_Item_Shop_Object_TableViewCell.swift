//
//  BF_Item_Shop_Object_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/04/2024.
//

import Foundation

public class BF_Item_Shop_Object_TableViewCell : BF_Item_Shop_TableViewCell {
	
	public override class var identifier: String {
		
		return "itemShopObjectTableViewCellIdentifier"
	}
	public override var item:BF_Item? {
		
		didSet {
			
			button.title = ["\(item?.price ?? 0)",String(key: "items.shop.coins")].joined(separator: " ")
			button.configuration?.imagePadding = UI.Margins/3
		}
	}
}
