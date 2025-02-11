//
//  BF_Items_Shop_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/08/2023.
//

import Foundation
import UIKit
import StoreKit

public class BF_Items_Shop_ViewController : BF_ViewController {
	
	private var objects:[BF_Item]? {
		
		didSet {
			
			tableView.reloadData()
		}
	}
	private var inAppPurchaseProducts:[(BF_Item?,SKProduct?)]? {
		
		didSet {
			
			tableView.reloadData()
		}
	}
	private lazy var segmentedControl:BF_SegmentedControl = {
		
		$0.selectedSegmentIndex = 0
		$0.addAction(.init(handler: { [weak self] _ in
			
			self?.tableView.reloadData()
			UIApplication.feedBack(.On)
			
		}), for: .valueChanged)
		return $0
		
	}(BF_SegmentedControl(items: [String(key: "items.shop.objects"),String(key: "items.shop.inAppPurchase")]))
	private lazy var tableView:BF_TableView = {
		
		$0.register(BF_Item_Shop_Object_TableViewCell.self, forCellReuseIdentifier: BF_Item_Shop_Object_TableViewCell.identifier)
		$0.register(BF_Item_Shop_InAppPurchase_TableViewCell.self, forCellReuseIdentifier: BF_Item_Shop_InAppPurchase_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		$0.separatorInset = .zero
		$0.separatorColor = .white.withAlphaComponent(0.25)
		return $0
		
	}(BF_TableView())
	private lazy var bannerView = BF_Ads.shared.presentBanner(BF_Ads.Identifiers.Banner.Shop, self)
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		navigationItem.title = String(key: "items.shop.title")
		
		navigationItem.rightBarButtonItems = [.init(customView: BF_Scans_StackView()),.init(customView: BF_Rubies_StackView()),.init(customView: BF_Coins_StackView())]
		
		let segmentedControlView:UIView = .init()
		segmentedControlView.addSubview(segmentedControl)
		segmentedControl.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins)
			make.top.bottom.equalToSuperview().inset(UI.Margins/2)
		}
		
		let stackView:UIStackView = .init(arrangedSubviews: [segmentedControlView,tableView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins
		view.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		if let bannerView {
			
			stackView.addArrangedSubview(bannerView)
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		launchRequest()
		
		bannerView?.isHidden = !BF_Ads.shared.shouldDisplayAd
	}
	
	private func launchRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_Item.get { [weak self] items, error in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
			
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchRequest()
				}
			}
			else {
				
				self?.objects = items?.filter({ $0.inAppPurchaseId?.isEmpty ?? true }).sorted(by: { $0.price ?? 0 < $1.price ?? 0 })
				
				self?.launchInAppRequest()
			}
		}
	}
	
	private func launchInAppRequest() {
		
		view.showPlaceholder(.Loading)
		
		BF_InAppPurchase.shared.requestProducts { [weak self] error, products in
			
			self?.view.dismissPlaceholder()
			
			if let error = error {
				
				self?.view.showPlaceholder(.Error,error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.launchInAppRequest()
				}
			}
			else {
				
				self?.inAppPurchaseProducts = products?.sorted(by: { $0.1?.price.doubleValue ?? 0.0 < $1.1?.price.doubleValue ?? 0.0 })
			}
		}
	}
	
	private var items:[BF_Item]? {
		
		return segmentedControl.selectedSegmentIndex == 0 ? objects : inAppPurchaseProducts?.compactMap({ $0.0 }).compactMap({ $0 })
	}
}

extension BF_Items_Shop_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return segmentedControl.selectedSegmentIndex == 0 ? items?.count ?? 0 : segmentedControl.selectedSegmentIndex == 1 ? inAppPurchaseProducts?.count ?? 0 : 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if segmentedControl.selectedSegmentIndex == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_Shop_Object_TableViewCell.identifier, for: indexPath) as! BF_Item_Shop_Object_TableViewCell
			cell.item = objects?[indexPath.row]
			return cell
		}
		else if segmentedControl.selectedSegmentIndex == 1 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: BF_Item_Shop_InAppPurchase_TableViewCell.identifier, for: indexPath) as! BF_Item_Shop_InAppPurchase_TableViewCell
			cell.inAppPurchase = inAppPurchaseProducts?[indexPath.row]
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BF_TableViewCell.identifier, for: indexPath) as! BF_TableViewCell
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
			
		if segmentedControl.selectedSegmentIndex == 0, let item = items?[indexPath.row] {
			
			if (BF_User.current?.coins ?? 0) >= (item.price ?? 0) {
				
				let alertController:BF_Alert_ViewController = .init()
				alertController.title = item.name
				
				if let picture = item.picture {
					
					alertController.add(UIImage(named: picture))
				}
				
				alertController.add(item.description)
				
				var numberString:String? = nil
				
				if [Items.ChestMonsters,Items.ChestObjects,Items.Potions.Hp,Items.Potions.Mp,Items.Potions.Revive].contains(item.uid) {
					
					numberString = "\(BF_User.current?.items.filter({ $0.uid == item.uid }).count ?? 0)"
				}
				else if item.uid == Items.Rubies {
					
					numberString = "\(BF_User.current?.rubies ?? 0)"
				}
				else if item.uid == Items.Scan {
					
					numberString = "\(BF_User.current?.scanAvailable ?? 0)"
				}
				else if item.uid == Items.MonsterPlace {
					
					numberString = "\(BF_Firebase.shared.config.int(.MaxMonstersCount) + (BF_User.current?.monstersPlaces ?? 0))"
				}
				
				if let numberString {
					
					let numberLabel = alertController.add(String(key: "items.shop.buy.alert.number") + numberString)
					numberLabel.set(font: Fonts.Content.Text.Bold, string: numberString)
				}
				
				alertController.add(String(key: "items.shop.buy.alert.content"))
				
				let label = alertController.add("")
				label.font = Fonts.Content.Title.H1
				
				let stepper:BF_Stepper = .init()
				stepper.maximumValue = Double((BF_User.current?.coins ?? 0) / (item.price ?? 0))
				stepper.minimumValue = 1.0
				stepper.value = 1.0
				
				let stepperView:UIView = .init()
				stepperView.addSubview(stepper)
				stepper.snp.makeConstraints { make in
					make.top.bottom.centerX.equalToSuperview()
				}
				alertController.add(stepperView)
				
				let buyButton = alertController.addButton(title: String(key: "items.shop.buy.alert.button.title")) { button in
					
					button?.isLoading = true
					
					BF_User.current?.coins -= Int(stepper.value) * (item.price ?? 0)
					
					if item.uid == Items.Rubies {
						
						BF_User.current?.rubies += Int(stepper.value)
					}
					else if item.uid == Items.Scan {
						
						BF_User.current?.scanAvailable += Int(stepper.value)
					}
					else if item.uid == Items.MonsterPlace {
						
						BF_User.current?.monstersPlaces += Int(stepper.value)
					}
					else {
						
						for _ in 0..<Int(stepper.value) {
							
							BF_User.current?.items.append(item)
						}
					}
					
					BF_User.current?.update({ error in
						
						button?.isLoading = false
						
						if let error = error {
							
							BF_Alert_ViewController.present(error)
							BF_User.current?.coins -= Int(stepper.value) * (item.price ?? 0)
							
							for _ in 0..<Int(stepper.value) {
								
								BF_User.current?.items.removeLast()
							}
						}
						else {
							
							NotificationCenter.post(.updateAccount)
							
							alertController.close()
							
							BF_Toast_Manager.shared.addToast(title: String(key: "items.shop.buy.toast.title"), subtitle: String(key: "items.shop.buy.toast.subtitle"), style: .Success)
						}
					})
				}
				
				stepper.addAction(.init(handler: { _ in
					
					label.text = "\(Int(stepper.value))"
					buyButton.subtitle = ["\(Int(stepper.value) * (item.price ?? 0))",String(key: "items.shop.buy.alert.button.subtitle")].joined(separator: " ")
					
				}), for: .valueChanged)
				
				stepper.sendActions(for: .valueChanged)
				
				alertController.addCancelButton()
				alertController.present(as: .Sheet)
			}
			else {
				
				let alertController = BF_Alert_ViewController.present(BF_Error(String(key: "items.shop.buy.error")))
				
				let button:BF_Button = .init(String(key: "items.shop.buy.error.button")) { [weak self] _ in
					
					alertController.close { [weak self] in
						
						self?.segmentedControl.selectedSegmentIndex = 1
						self?.segmentedControl.sendActions(for: .valueChanged)
					}
				}
				button.image = UIImage(named: "items_coins")
				alertController.contentStackView.insertArrangedSubview(button, at: alertController.contentStackView.arrangedSubviews.count-1)
			}
		}
		else if segmentedControl.selectedSegmentIndex == 1,
					let item = inAppPurchaseProducts?[indexPath.row].0,
					let product = inAppPurchaseProducts?[indexPath.row].1 {
			
			BF_Alert_ViewController.presentLoading() { alertController in
				
				BF_InAppPurchase.shared.purchase(product) { transaction in
					
					alertController?.close {
						
						if transaction != nil {
							
							if item.uid == Items.RemoveAds {
								
								BF_User.current?.removeAds = true
							}
							else {
								
								BF_User.current?.coins += item.price ?? 0
							}
							
							BF_Alert_ViewController.presentLoading() { alertController in
								
								BF_User.current?.update({ error in
									
									alertController?.close {
										
										if let error {
											
											if item.uid == Items.RemoveAds {
												
												BF_User.current?.removeAds = false
											}
											else {
												
												BF_User.current?.coins -= item.price ?? 0
											}
											
											BF_Alert_ViewController.present(error)
										}
										else {
											
											NotificationCenter.post(.updateAccount)
											
											BF_Toast_Manager.shared.addToast(title: String(key: "items.shop.buy.toast.title"), subtitle: String(key: "items.shop.buy.toast.subtitle"), style: .Success)
										}
									}
								})
							}
						}
						else {
							
							BF_Alert_ViewController.present(BF_Error(String(key: "items.shop.buy.inApp.error")))
						}
					}
				}
			}
		}
	}
}
