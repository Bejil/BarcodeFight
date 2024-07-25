//
//  BF_Fight.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 14/08/2023.
//

import Foundation

public class BF_Fight : NSObject, Codable {
	
	public enum State : Int, Codable {
		
		case Victory = 0
		case Defeat = 1
		case Dropout = 2
	}
	
	public class Player : Codable {
		
		public var userId:String?
		public var displayName:String?
		public var monstersIds:[String]?
	}
	
	public var creationDate:Date = Date()
	public var creator:Player = .init()
	public var opponent:Player = .init()
	public var state:State?
	
	public override init() {
		
		super.init()
		
		creator.userId = BF_User.current?.uid
		creator.displayName = BF_User.current?.displayName
	}
}
