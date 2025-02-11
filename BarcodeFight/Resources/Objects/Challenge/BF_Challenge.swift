//
//  BF_Challenge.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 28/08/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

public class BF_Challenge : Codable {
	
	@DocumentID public var id: String?
	public var uid:String?
	public var name:String?
	public var description:String?
	public var dates:[Date]?
}

extension BF_Challenge {
	
	public static func get(_ completion:(([BF_Challenge]?,Error?)->Void)?) {
		
		Firestore.firestore().collection("challenges").getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Challenge.self) }),error)
		}
	}
}
