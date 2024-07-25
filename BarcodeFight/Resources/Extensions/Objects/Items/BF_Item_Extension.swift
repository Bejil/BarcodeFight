//
//  BF_Item_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/04/2024.
//

import Foundation

extension BF_Item {
	
	public static func getRewards(_ completion:(([BF_Item]?,Error?)->Void)?) {
		
		BF_Item.get { items, error in
			
			if let error {
				
				completion?(nil,error)
			}
			else {
				
				var rewards = items?.filter({ $0.isReward ?? false && Int.random(in: 1...100) <= Int(($0.rewardRate ?? 0.0) * 100.0) })
				
				if BF_User.current?.scanAvailable ?? 0 >= BF_Firebase.shared.config.int(.ScanMaxNumber) {
					
					rewards?.removeAll(where: { $0.uid == Items.Scan })
				}
				
				if BF_User.current?.rubies ?? 0 >= BF_Firebase.shared.config.int(.RubiesMaxNumber) {
					
					rewards?.removeAll(where: { $0.uid == Items.Rubies })
				}
					
				completion?(rewards,nil)
			}
		}
	}
}
