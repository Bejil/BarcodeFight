//
//  BF_Item_Object_TableViewCell.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/04/2024.
//

import Foundation

public class BF_Item_Object_TableViewCell : BF_Item_TableViewCell {
	
	public override class var identifier: String {
		
		return "itemObjectTableViewCellIdentifier"
	}
	public var count:Int? {
		
		didSet {
			
			button.title = "x\(count ?? 0)"
		}
	}
}
