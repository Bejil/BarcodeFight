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
			
			let alertController:BF_Alert_ViewController = .init()
			alertController.title = String(key: "monsters.scan.empty.alert.title")
			alertController.add(UIImage(named: "placeholder_empty"))
			alertController.add(String(key: "monsters.scan.empty.alert.label.0"))
			alertController.add(String(key: "monsters.scan.empty.alert.label.1"))
			
			let nextScanAlertControllerLabel:BF_Label = .init(BF_Scan.shared.nextScanString)
			nextScanAlertControllerLabel.font = Fonts.Content.Title.H3
			nextScanAlertControllerLabel.textAlignment = .center
			alertController.add(nextScanAlertControllerLabel)
			
			var nextFreeScanTimer:Timer? = nil
			nextFreeScanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
				
				if BF_User.current?.scanAvailable ?? 0 <= 0 {
					
					nextScanAlertControllerLabel.text = BF_Scan.shared.nextScanString
				}
				else {
					
					alertController.close()
				}
			}
			
			alertController.addButton(title: String(key: "monsters.scan.empty.button"), image: UIImage(named: "scan_icon")) { _ in
				
				alertController.close {
					
					UI.MainController.present(BF_NavigationController(rootViewController: BF_Items_Shop_ViewController()), animated: true)
				}
			}
			
			alertController.addButton(title: String(key: "monsters.scan.empty.free.button.title"), subtitle: String(key: "monsters.scan.empty.free.button.subtitle")) { button in
				
				button?.isLoading = true
				
				BF_Ads.shared.presentRewardedInterstitial(BF_Ads.Identifiers.FullScreen.FreeScan) {
					
					alertController.close {
						
						let alertController:BF_Alert_ViewController = .presentLoading()
						
						BF_User.current?.scanAvailable += 1
						BF_User.current?.update({ error in
							
							alertController.close {
								
								if let error {
									
									BF_User.current?.scanAvailable -= 1
									BF_Alert_ViewController.present(error)
								}
								else {
									
									NotificationCenter.post(.updateAccount)
									BF_Scan.scan()
								}
							}
						})
					}
				}
			}
			
			alertController.addDismissButton()
			alertController.present()
			alertController.dismissHandler = {
				
				nextFreeScanTimer?.invalidate()
				nextFreeScanTimer = nil
			}
		}
		else {
			
			BF_Authorizations.shared.askIfNeeded(.camera) { status in
				
				if status {
					
					let handler:((String?)->Void) = { code in
						
						if let code = code {
							
//							let alertController:BF_Alert_ViewController = .presentLoading()
							
							BF_Monster.get(code) { monster, error in
								
								if let error = error {
									
//									alertController.close {
										
										BF_Alert_ViewController.present(error)
//									}
								}
								else {
									
									let completion:((BF_Monster)->Void) = { monster in
										
//										alertController.close {
											
											let viewController:BF_Monsters_Details_Add_ViewController = .init()
											viewController.monster = monster
											UI.MainController.present(viewController, animated: true)
//										}
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
															
//															alertController.close {
															
																BF_Alert_ViewController.present(error)
//															}
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
						else {
							
							BF_Alert_ViewController.present(BF_Error(String(key: "monsters.scan.error")))
						}
					}
					
//					if UIApplication.isDebug {
//						
//						let alertController:BF_Alert_ViewController = .presentLoading()
//						
//						UIApplication.wait(1.5) {
//							
//							alertController.close {
//								
//								handler(.randomBarCode)
//							}
//						}
//					}
//					else {
						
						let viewController:BF_Scanner_ViewController = .init()
						viewController.handler = handler
						UI.MainController.present(viewController, animated: true)
//					}
				}
			}
		}
	}
}
