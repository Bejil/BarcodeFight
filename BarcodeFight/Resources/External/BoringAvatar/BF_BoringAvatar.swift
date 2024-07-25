//
//  BF_BoringAvatar.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 29/04/2024.
//

import Foundation
import Alamofire
import SVGKit

public class BF_BoringAvatar {
	
	public static func get(for name:String?, _ completion:((UIImage?)->Void)?) {
		
		let urlString = "https://source.boringavatars.com/beam/120/\(name ?? "")?square&colors=\(Colors.Primary.hex ?? ""),\(Colors.Secondary.hex ?? "")"
		
		if let url = URL(string: urlString) {
			
			AF.request(url).validate().responseData(completionHandler: { response in
				
				DispatchQueue.main.async {
					
					if let data = response.data, response.error == nil {
						
						if let receivedImage: SVGKImage = SVGKImage(data: data) {
							
							completion?(receivedImage.uiImage)
						}
						else {
							
							completion?(nil)
						}
					}
				}
			})
		}
		else {
			
			completion?(nil)
		}
	}
}
