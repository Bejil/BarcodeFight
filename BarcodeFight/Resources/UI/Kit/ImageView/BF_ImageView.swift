//
//  BF_ImageView.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 23/06/2023.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

public class BF_ImageView : UIImageView {
	
	public var url:String? {
		
		didSet {
			
			if let url = url {
				
				showLoadingIndicatorView()
				
				AF.request(url).validate().responseImage { [weak self] (response) in
					
					DispatchQueue.main.async { [weak self] in
						
						self?.dismissLoadingIndicatorView()
						
						if case .success(let image) = response.result {
							
							self?.image = image
						}
					}
				}
			}
		}
	}
}
