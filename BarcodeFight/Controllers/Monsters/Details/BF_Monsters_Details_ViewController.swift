//
//  BF_Monsters_Details_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 11/08/2023.
//

import Foundation
import UIKit
import SpriteKit
import MapKit

public class BF_Monsters_Details_ViewController : BF_ViewController {
	
	public var index:Int?
	public var monster:BF_Monster? {
		
		didSet {
			
			fullStackView.monster = monster
			
			let hp = monster?.stats.hp ?? Int(BF_Monster.Stats.range.lowerBound)
			let statusHp = monster?.status.hp ?? Int(BF_Monster.Stats.range.lowerBound)
			statusHpProgressView.progress = Float(statusHp)/Float(hp)
			statusHpProgressView.value = String(statusHp)
			
			let mp = monster?.stats.mp ?? Int(BF_Monster.Stats.range.lowerBound)
			let statusMp = monster?.status.mp ?? Int(BF_Monster.Stats.range.lowerBound)
			statusMpProgressView.progress = Float(statusMp)/Float(mp)
			statusMpProgressView.value = String(statusMp)
			
			if let creationDate = monster?.creationDate {
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				dateLabel.text = [String(key: "monsters.createDate.label"),dateFormatter.string(from: creationDate)].joined(separator: " ")
			}
			
			if let scanDate = monster?.scanDate {
				
				let dateFormatter:DateFormatter = .init()
				dateFormatter.dateFormat = "dd/MM/yyyy"
				dateLabel.text = [dateLabel.text,[String(key: "monsters.scanDate.label"),dateFormatter.string(from: scanDate)].joined(separator: " ")].compactMap({ $0 }).joined(separator: "  |  ")
			}
			
			fightsStackView.fights = monster?.fights
			
			updateProduct()
			
			barcCodeStackView.barcode = monster?.barcode
			
			if let latitude = monster?.location?.coordinates?.latitude, let longitude = monster?.location?.coordinates?.longitude {
				
				mapView.isHidden = false
				
				let annotation:MKPointAnnotation = .init()
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				annotation.title = [monster?.location?.street,monster?.location?.postalCode,monster?.location?.city].compactMap({ $0 }).joined(separator: " - ")
				mapView.addAnnotation(annotation)
				mapView.showAnnotations(mapView.annotations, animated: true)
				mapView.selectAnnotation(annotation, animated: true)
			}
		}
	}
	private lazy var fullStackView:BF_Monsters_Full_StackView = {
		
		let statusLabel:BF_Label = .init(String(key: "monsters.status.label"))
		statusLabel.font = Fonts.Content.Title.H4
		statusLabel.textAlignment = .center
		statusLabel.contentInsets.bottom = UI.Margins/2
		statusLabel.addLine(position: .bottom)
		$0.addArrangedSubview(statusLabel)
		
		let statusStackView:UIStackView = .init(arrangedSubviews: [statusHpProgressView,statusMpProgressView])
		statusStackView.axis = .vertical
		statusStackView.spacing = UI.Margins/3
		statusStackView.isLayoutMarginsRelativeArrangement = true
		statusStackView.layoutMargins = .init(horizontal: 2*UI.Margins)
		$0.addArrangedSubview(statusStackView)
		
		let detailsLabel:BF_Label = .init(String(key: "monsters.informations.label"))
		detailsLabel.font = Fonts.Content.Title.H4
		detailsLabel.textAlignment = .center
		detailsLabel.contentInsets.bottom = UI.Margins/2
		detailsLabel.addLine(position: .bottom)
		$0.addArrangedSubview(detailsLabel)
		
		let productStackView:UIStackView = .init(arrangedSubviews: [barcCodeStackView])
		productStackView.axis = .vertical
		productStackView.alignment = .center
		
		let productButton:BF_Button = .init(String(key: "monsters.product.add.button")) { [weak self] _ in
			
			let alertController:BF_Product_Add_Alert_ViewController = .init()
			alertController.completion = { [weak self] name, image in
				
				BF_Alert_ViewController.presentLoading() { [weak self] alertController in
					
					self?.monster?.updateProduct(name: name, image: image, { [weak self] error in
						
						alertController?.close { [weak self] in
							
							if let error {
								
								BF_Alert_ViewController.present(error)
							}
							else {
								
								BF_Alert_ViewController.presentLoading() { [weak self] alertController in
									
									BF_User.current?.monsters.first(where: { $0.uid == self?.monster?.uid })?.product = self?.monster?.product
									BF_User.current?.update({ [weak self] error in
										
										alertController?.close { [weak self] in
											
											if let error {
												
												BF_Alert_ViewController.present(error)
											}
											else {
												
												self?.updateProduct()
											}
										}
									})
								}
							}
						}
						
					})
				}
			}
			alertController.present()
		}
		productButton.isPrimary = false
		
		let informationsStackView:UIStackView = .init(arrangedSubviews: [fightsStackView,dateLabel,productNameLabel,productImageView,productStackView,productButton,mapView])
		informationsStackView.axis = .vertical
		informationsStackView.spacing = 1.5*UI.Margins
		$0.addArrangedSubview(informationsStackView)
		
		return $0
	}(BF_Monsters_Full_StackView())
	private lazy var statusHpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "heart")
		$0.color = Colors.Monsters.Stats.Hp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var statusMpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "wand.and.stars")
		$0.color = Colors.Monsters.Stats.Mp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var dateLabel:BF_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		$0.textColor = Colors.Content.Text
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var fightsStackView:BF_Fights_StackView = .init()
	private lazy var productNameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var productImageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.height.equalTo(200)
		}
		$0.isUserInteractionEnabled = true
		return $0
		
	}(BF_ImageView(image: UIImage(named: "placeholder_empty")))
	private lazy var barcCodeStackView:BF_Barcode_StackView = .init()
	private lazy var mapView:MKMapView = {
		
		$0.isHidden = true
		$0.layer.cornerRadius = UI.CornerRadius
		$0.snp.makeConstraints { make in
			make.height.equalTo(150)
		}
		$0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
			
			if let monster = self?.monster {
				
				let viewController:BF_Monsters_Locations_ViewController = .init()
				viewController.monsters = [monster]
				UI.MainController.present(viewController, animated: true)
			}
		}))
		return $0
		
	}(MKMapView())
	public lazy var scrollView:UIScrollView = {
		
		$0.addSubview(fullStackView)
		fullStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview().inset(UI.Margins)
		}
		return $0
		
	}(UIScrollView())
	
	public override func loadView() {
		
		super.loadView()
		
		if parent is UIPageViewController {
			
			view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
		}
		
		isModal = true
		
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	private func updateProduct() {
		
		productNameLabel.text = !(monster?.product?.name?.isEmpty ?? true) ? monster?.product?.name : String(key: "monsters.product.label")
		
		productImageView.image = UIImage(named: "placeholder_empty")
		
		if let picture = monster?.product?.picture, !picture.isEmpty {
			
			productImageView.url = picture
		}
	}
}
