//
//  BF_Scan_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 02/05/2024.
//

import Foundation
import UIKit
import SwiftLocation

extension BF_Scan {
	
	public static func scan() {
		
		if BF_User.current?.scanAvailable ?? 0 <= 0 {
			
			let alertController:BF_Scans_Alert_ViewController = .init()
			alertController.present()
		}
		else {
			
			BF_Authorizations.shared.askIfNeeded(.camera) { status in
				
				if status {
					
					let handler:((String?)->Void) = { code in
						
						if let code = code {
							
							BF_Alert_ViewController.presentLoading() { alertController in
								
								BF_Monster.get(code) { monster, error in
									
									if let error = error {
										
										alertController?.close {
											
											BF_Alert_ViewController.present(error)
										}
									}
									else {
										
										let completion:((BF_Monster)->Void) = { monster in
											
											alertController?.close {
												
												let viewController:BF_Monsters_Details_Add_ViewController = .init()
												viewController.monster = monster
												UI.MainController.present(viewController, animated: true)
											}
										}
										
										if let monster = monster {
											
											completion(monster)
										}
										else {
											
											BF_Authorizations.shared.askIfNeeded(.locationWhenInUse) { state in
												
												let createCompletion:((BF_Monster)->Void) = { monster in
													
													BF_BarcodeLookup.shared.barcode = code
													BF_BarcodeLookup.shared.search { product in
														
														monster.product = product
														
														monster.save { error in
															
															if let error = error {
																
																alertController?.close {
																	
																	BF_Alert_ViewController.present(error)
																}
															}
															else {
																
																completion(monster)
															}
														}
													}
												}
												
												let defaultCompletion:(()->Void) = {
													
													let monster:BF_Monster = .init(from: code)
													createCompletion(monster)
												}
												
												if state {
													
													SwiftLocation.gpsLocationWith {
														
														$0.subscription = .single
														$0.accuracy = .city
														$0.timeout = .delayed(5)
														
													}.then { result in
														
														switch result {
														case .success(let location):
															
															let service = Geocoder.Apple(coordinates: location.coordinate)
															SwiftLocation.geocodeWith(service).then { result in
																
																switch result {
																case .success(let geocode):
																	
																	let monster:BF_Monster = .init(from: code, with: geocode.first?.clPlacemark)
																	createCompletion(monster)
																	
																case .failure(_):
																	
																	defaultCompletion()
																}
															}
															
														case .failure(_):
															
															defaultCompletion()
														}
													}
												}
												else {
													
													defaultCompletion()
												}
											}
										}
									}
								}
							}
						}
						else {
							
							BF_Alert_ViewController.present(BF_Error(String(key: "monsters.scan.error")))
						}
					}
					
#if DEBUG
					BF_Alert_ViewController.presentLoading() { alertController in
						
						UIApplication.wait(1.5) {
							
							alertController?.close {
								
								handler(.randomBarCode)
							}
						}
					}
#else
					let viewController:BF_Scanner_ViewController = .init()
					viewController.handler = handler
					UI.MainController.present(viewController, animated: true)
#endif
				}
			}
		}
	}
}
