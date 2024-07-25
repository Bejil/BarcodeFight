//
//  BF_Item_Shop_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/04/2024.
//

import Foundation
import UIKit

public class BF_Item_Shop_TableViewCell : BF_Item_TableViewCell {
	
	public override class var identifier: String {
		
		return "itemShopTableViewCellIdentifier"
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		button.image = UIImage(systemName: "cart.badge.plus")
		button.titleFont = Fonts.Content.Text.Bold.withSize(Fonts.Size-4)
		button.style = .solid
		button.isPrimary = true
		button.isEnabled = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
