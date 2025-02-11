//
//  BF_User.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/05/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

public class BF_User : Codable, Equatable {
	
	public static func == (lhs: BF_User, rhs: BF_User) -> Bool {
		
		return lhs.uid == rhs.uid
	}
	
	static public var current:BF_User?
	@DocumentID public var id: String?
	public var creationDate:Date = Date()
	public var lastConnexionDate:Date = Date()
	public var uid:String?
	public var isSoundsEnabled:Bool = true
	public var isMusicEnabled:Bool = true
	public var displayName:String?
	public var pictureUrl:String?
	public var monsters:[BF_Monster] = .init()
	public var experience:Int = 0
	public var fights:[BF_Fight] = .init()
	public var scanCount:Int = 0
	public var scanAvailable:Int = 5
	public var items:[BF_Item] = .init()
	public var coins:Int = 5
	public var rubies:Int = 5
	public var monstersPlaces:Int = 0
	public var currentStoryPoint:Int = 1
	public var removeAds:Bool = false
	public var ranking:Int {
		
		let fightPoints = fights.reduce(0) { result, fight in
			
			switch fight.state {
			case .Victory:
				return result + 3
			case .Defeat:
				return result + 1
			case .Dropout:
				return result
			case .none:
				return result
			}
		}
		
		return fightPoints + currentStoryPoint
	}
	public var challenges:BF_Challenges = .init()
	public var isAdmin:Bool = false
	public var newsRead:[String] = .init()
}

extension BF_User {
	
	public static func getAll(_ completion:(([BF_User]?,Error?)->Void)?) {
		
		Firestore.firestore().collection("users").getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_User.self) }),error)
		}
	}
	
	public static func get(_ uid:String?, _ completion:((BF_User?,Error?)->Void)?) {
		
		Firestore.firestore().collection("users").whereField("uid", isEqualTo: uid ?? "").getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_User.self) }).first,error)
		}
	}
	
	public static func get(_ completion:((Error?)->Void)?) {
		
		get(BF_Account.shared.user?.uid) { user, error in
			
			if let user = user {
				
				BF_User.current = user
			}
			
			completion?(error)
		}
	}
	
	public static func create(_ completion:((Error?)->Void)?) {
		
		do {
			
			let lc_user:BF_User = .init()
			lc_user.uid = BF_Account.shared.user?.uid
			
			try Firestore.firestore().collection("users").addDocument(from: lc_user)
			completion?(nil)
		}
		catch {
			
			completion?(error)
		}
	}
	
	public func update(_ completion:((Error?)->Void)?) {
		
		let docRef = Firestore.firestore().collection("users").document(id ?? "")
		try?docRef.setData(from: self) { error in
			
			completion?(error)
		}
	}
	
	public static func update(profilePicture:UIImage?, _ completion:((Error?)->Void)?) {
		
		if let data = profilePicture?.png() {
			
			let profileImgReference = Storage.storage().reference().child("profile_pictures").child("\(BF_User.current?.uid ?? "").png")
			
			profileImgReference.putData(data, metadata: nil) { _, error in
				
				if let error = error {
					
					completion?(error)
				}
				else {
					
					profileImgReference.downloadURL() { url, error in
						
						if let error = error {
							
							completion?(error)
						}
						else if let url = url{
							
							BF_User.current?.pictureUrl = url.absoluteString
							BF_User.current?.update(completion)
						}
					}
				}
			}
		}
	}
	
	public static func getRandom(_ completion:((Error?,BF_User?)->Void)?) {
		
		Firestore.firestore().collection("users").whereField("uid", isNotEqualTo: BF_Account.shared.user?.uid ?? "").getDocuments { querySnapshot, error in
			
			completion?(error,querySnapshot?.documents.compactMap({ try?$0.data(as: BF_User.self) }).filter({ !$0.monsters.filter({ !$0.isDead }).isEmpty }).randomElement())
		}
	}
	
	public func increaseChallenge(_ id: String) {
		
		if !challenges.items.contains(where: { $0.uid == id }) {
			
			let challenge: BF_Challenge = .init()
			challenge.uid = id
			challenge.dates = []
			challenges.items.append(challenge)
		}
		
		let challenge = challenges.items.first(where: { $0.uid == id })
		
		guard let dates = challenge?.dates else {
			
			challenge?.dates = [Date()]
			return
		}
		
		let today = Date()
		
		let sortedDates = dates.sorted()
		
		if let lastDate = sortedDates.last, Calendar.current.isDate(lastDate, inSameDayAs: today) {
			
			return
		}
		
		let lastSevenDates = sortedDates.suffix(7)
		var areConsecutive = true
		
		if lastSevenDates.count > 1 {
			
			for i in 1..<lastSevenDates.count {
				
				if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: lastSevenDates[i - 1]) {
					
					if !Calendar.current.isDate(previousDay, inSameDayAs: lastSevenDates[i]) {
						
						areConsecutive = false
						break
					}
				}
			}
		}
		
		if areConsecutive && lastSevenDates.count == 7 {
			
			return
		}
		
		challenge?.dates?.append(today)
		
		update(nil)
	}
}
