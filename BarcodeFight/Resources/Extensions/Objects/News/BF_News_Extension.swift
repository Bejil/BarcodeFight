//
//  BF_News_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/01/2025.
//

extension BF_News {
	
	public var isRead:Bool {
		
		if let id {
				
			return BF_User.current?.newsRead.contains(id) ?? false
		}
		
		return false
	}
	
	public static func getUnreadCount(_ completion:((Int)->Void)?) {
		
		BF_News.get { news, error in
			
			completion?(news?.filter({!$0.isRead}).count ?? 0)
		}
	}
}
