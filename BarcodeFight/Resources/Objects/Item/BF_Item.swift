//
//  BF_Item.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

public class BF_Item : Codable, Hashable {
	
	public static func == (lhs: BF_Item, rhs: BF_Item) -> Bool {
		
		return lhs.uid == rhs.uid
	}
	
	public func hash(into hasher: inout Hasher) {
		
		hasher.combine(uid)
	}
	
	@DocumentID public var id:String?
	public var uid:String?
	public var name:String?
	public var description:String?
	public var picture:String?
	public var price:Int?
	public var inAppPurchaseId:String?
	public var isReward:Bool?
	public var rewardRate:Double?
}

extension BF_Item {
	
	public static func get(_ completion:(([BF_Item]?,Error?)->Void)?) {
		
		Firestore.firestore().collection("items").getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Item.self) }),error)
		}
	}
}
