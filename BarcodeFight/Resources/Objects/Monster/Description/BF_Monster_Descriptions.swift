//
//  BF_Monster_Descriptions.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 14/08/2023.
//

import Foundation

public class BF_Monster_Descriptions : NSObject {
	
	private var descriptions:[String]?
	public static let shared:BF_Monster_Descriptions = .init()
	
	public override init() {
		
		super.init()
		
		if let path = Bundle.main.path(forResource: "BF_Monster_Descriptions", ofType: "json"), let data = FileManager.default.contents(atPath: path){

			descriptions = try?JSONDecoder().decode([String].self, from: data)
		}
	}
	
	public func random() -> String? {
		
		return descriptions?.randomElement()
	}
}
