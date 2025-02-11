//
//  BF_News.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/01/2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

public class BF_News : Codable {
	
	@DocumentID public var id: String?
	public var title:String?
	public var content:String?
	@ServerTimestamp public var creationDate: Date?
	@ServerTimestamp public var modificationDate: Date?
}

extension BF_News {
	
	public static func get(_ completion:(([BF_News]?,Error?)->Void)?) {
		
		Firestore.firestore().collection("news").order(by: "creationDate", descending: true).getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_News.self) }),error)
		}
	}
}
