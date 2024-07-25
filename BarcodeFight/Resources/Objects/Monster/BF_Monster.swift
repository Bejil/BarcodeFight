//
//  BF_Monster.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/07/2023.
//

import Foundation
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

public class BF_Monster : Codable, Equatable {
	
	public static func == (lhs: BF_Monster, rhs: BF_Monster) -> Bool {
		
		return lhs.barcode == rhs.barcode
	}
	
	public class Product : Codable {
		
		public var name:String?
		public var picture:String?
	}
	
	public enum Genre : Int, Codable, CaseIterable {
		
		case Male = 0
		case Femelle = 1
	}
	
	public class Stats : Codable {
		
		public enum Rank : Int, Codable, CaseIterable, Comparable {
			
			public static func < (lhs: BF_Monster.Stats.Rank, rhs: BF_Monster.Stats.Rank) -> Bool {
				
				return lhs.rawValue < rhs.rawValue
			}
			
			case N = 0
			case R = 1
			case SR = 2
			case SSR = 3
			case UR = 4
			case LR = 5
		}
		
		public static var range: Range<Double> = (100.0)..<(1000.0)
		public var hp: Int = Int(Stats.skewedRandomValue(in: Stats.range))
		public var mp: Int = Int(Stats.skewedRandomValue(in: Stats.range))
		public var atk: Int = Int(Stats.skewedRandomValue(in: Stats.range))
		public var def: Int = Int(Stats.skewedRandomValue(in: Stats.range))
		public var luk: Int = Int(Stats.skewedRandomValue(in: Stats.range))
		public var height: Double = Stats.skewedRandomValue(in: Stats.range)
		public var weight: Double = Stats.skewedRandomValue(in: Stats.range)
		
		public var rank: Rank {
			let slice: Double = Stats.range.upperBound / Double(Rank.allCases.count)
			let stats = [hp, mp, atk, def]
			let total: Double = Double(stats.reduce(0, { $0 + $1 }))
			let average: Double = total / Double(stats.count)
			
			if average >= Double(Rank.R.rawValue) * slice, average < Double(Rank.SR.rawValue) * slice {
				return .R
			} else if average >= Double(Rank.SR.rawValue) * slice, average < Double(Rank.SSR.rawValue) * slice {
				return .SR
			} else if average >= Double(Rank.SSR.rawValue) * slice, average < Double(Rank.UR.rawValue) * slice {
				return .SSR
			} else if average >= Double(Rank.UR.rawValue) * slice, average < Double(Rank.LR.rawValue) * slice {
				return .UR
			} else if average >= Double(Rank.LR.rawValue) * slice {
				return .LR
			}
			
			return .N
		}
		
		private static func skewedRandomValue(in range: Range<Double>, skewFactor: Double = 3.0) -> Double {
			
			let base = Double.random(in: 0..<1)
			let skewed = pow(base, skewFactor)
			return range.lowerBound + skewed * (range.upperBound - range.lowerBound)
		}
	}
	
	public class Location : Codable {
		
		public class Coordinates : Codable {
			
			public var latitude:Double?
			public var longitude:Double?
		}
		
		public var coordinates:Coordinates?
		public var street:String?
		public var postalCode:String?
		public var city:String?
		public var country:String?
		
		convenience init(from placemark:CLPlacemark? = nil) {
			
			self.init()
			
			if let placemark = placemark {
				
				coordinates = .init()
				coordinates?.latitude = placemark.location?.coordinate.latitude
				coordinates?.longitude = placemark.location?.coordinate.longitude
				
				street = placemark.thoroughfare
				postalCode = placemark.postalCode
				city = placemark.locality
				country = placemark.country
			}
		}
	}
	
	public enum Element : Int, Codable, CaseIterable, Comparable {
		
		public static func < (lhs: Element, rhs: Element) -> Bool {
			
			return (lhs == .Fire && rhs == .Water) ||
			(lhs == .Ice && rhs == .Fire) ||
			(lhs == .Wind && rhs == .Ice) ||
			(lhs == .Earth && rhs == .Wind) ||
			(lhs == .Electricity && rhs == .Earth) ||
			(lhs == .Water && rhs == .Electricity) ||
			(lhs == .Lightness && rhs == .Darkness) ||
			(lhs == .Darkness && rhs == .Lightness) ||
			(lhs == .Neutral && rhs != .Neutral)
		}
		
		case Fire = 0
		case Ice = 1
		case Wind = 2
		case Earth = 3
		case Electricity = 4
		case Water = 5
		case Lightness = 6
		case Darkness = 7
		case Neutral = 8
	}
	
	public class Status : Codable {
		
		public var hp:Int = 0
		public var mp:Int = 0
	}
	
	@DocumentID public var id:String?
	public var uid:String = UUID().uuidString
	public var creationDate:Date = Date()
	public var scanDate:Date?
	public var barcode:String = String.randomBarCode
	public var name:String = BF_Markov().randomName
	public var description:String? = BF_Monster_Descriptions.shared.random()
	public var genre:Genre = Genre.allCases.randomElement() ?? .Male
	public var picture:String = "monster_\(Int.random(in: 0 ..< 990))"
	public var stats:Stats = .init()
	public var location:Location?
	public var fights:[BF_Fight] = .init()
	public var element:Element = Element.allCases.randomElement() ?? .Neutral
	public var status:Status = .init()
	public var product:Product?
	
	convenience init(from code:String, with placemark:CLPlacemark? = nil) {
		
		self.init()
		
		barcode = code
		location = .init(from: placemark)
		status.hp = stats.hp
		status.mp = stats.mp
	}
}

extension BF_Monster {
	
	public static func getAllWithProduct(_ completion:(([BF_Monster]?,Error?)->Void)?) {
		
		Firestore.firestore().collection("monsters").whereField("product", isNotEqualTo: NSNull()).getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Monster.self) }),error)
		}
	}
	
	public static func get(_ code:String, _ completion:((BF_Monster?,Error?)->Void)?) {
		
		Firestore.firestore().collection("monsters").whereField("barcode", isEqualTo: code).getDocuments { querySnapshot, error in
			
			completion?(querySnapshot?.documents.compactMap({ try?$0.data(as: BF_Monster.self) }).first,error)
		}
	}
	
	public func save(_ completion:((Error?)->Void)?) {
		
		do {
			
			scanDate = .init()
			try Firestore.firestore().collection("monsters").addDocument(from: self)
			completion?(nil)
		}
		catch {
			
			completion?(error)
		}
	}
	
	public func updateProduct(name:String?, image:UIImage?, _ completion:((Error?)->Void)?) {
		
		if let id, let data = image?.png() {
			
			let profileImgReference = Storage.storage().reference().child("product_pictures").child("\(barcode).png")
			
			profileImgReference.putData(data, metadata: nil) { [weak self] _, error in
				
				if let error = error {
					
					completion?(error)
				}
				else {
					
					profileImgReference.downloadURL() { [weak self] url, error in
						
						if let error = error {
							
							completion?(error)
						}
						else if let url = url, let weakSelf = self {
							
							weakSelf.product = .init()
							weakSelf.product?.name = name
							weakSelf.product?.picture = url.absoluteString
							
							let documentRef = Firestore.firestore().collection("monsters").document(id)
							try?documentRef.setData(from: weakSelf, completion: completion)
						}
					}
				}
			}
		}
	}
}
