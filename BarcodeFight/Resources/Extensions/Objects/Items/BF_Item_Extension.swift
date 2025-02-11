//
//  BF_Item_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/04/2024.
//

import Foundation
import Firebase

extension BF_Item {
	
	public static func getRewards(_ completion:(([BF_Item]?,Error?)->Void)?) {
		
		BF_Item.get { items, error in
			
			if let error {
				
				completion?(nil,error)
			}
			else {
				
				let rewards = items?.filter({ $0.isReward ?? false && Int.random(in: 1...100) <= Int(($0.rewardRate ?? 0.0) * 100.0) })
				completion?(rewards,nil)
			}
		}
	}
}
