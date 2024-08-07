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
			
			pictureImageView.monster = monster
			particulesView.monster = monster
			rankLabel.text = monster?.stats.rank.readable
			elementView.element = monster?.element
			nameLabel.text = monster?.name
			
			genreLabel.text = monster?.genre.readable
			heightLabel.text = monster?.stats.readableHeight
			weightLabel.text = monster?.stats.readableWeight
			
			descriptionLabel.text = monster?.description
			
			let hp = monster?.stats.hp ?? Int(BF_Monster.Stats.range.lowerBound)
			hpProgressView.progress = Float(hp)/Float(BF_Monster.Stats.range.upperBound)
			hpProgressView.value = String(hp)
			
			let mp = monster?.stats.mp ?? Int(BF_Monster.Stats.range.lowerBound)
			mpProgressView.progress = Float(mp)/Float(BF_Monster.Stats.range.upperBound)
			mpProgressView.value = String(mp)
			
			let atk = monster?.stats.atk ?? Int(BF_Monster.Stats.range.lowerBound)
			atkProgressView.progress = Float(atk)/Float(BF_Monster.Stats.range.upperBound)
			atkProgressView.value = String(atk)
			
			let def = monster?.stats.def ?? Int(BF_Monster.Stats.range.lowerBound)
			defProgressView.progress = Float(def)/Float(BF_Monster.Stats.range.upperBound)
			defProgressView.value = String(def)
			
			let luk = monster?.stats.luk ?? Int(BF_Monster.Stats.range.lowerBound)
			lukProgressView.progress = Float(luk)/Float(BF_Monster.Stats.range.upperBound)
			lukProgressView.value = String(luk)
			
			elementsStackView.monster = monster
			
			let statusHp = monster?.status.hp ?? Int(BF_Monster.Stats.range.lowerBound)
			statusHpProgressView.progress = Float(statusHp)/Float(hp)
			statusHpProgressView.value = String(statusHp)
			
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
	private lazy var pictureView:UIView = {
		
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins*20)
		}
		
		$0.addSubview(particulesView)
		particulesView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let gradient:CAGradientLayer = .init()
		gradient.frame = $0.bounds
		gradient.opacity = 0.5
		gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
		gradient.locations = [0.0, 1.0]
		$0.layer.addSublayer(gradient)
		
		pictureViewObserver = $0.layer.observe(\.bounds) { object, _ in
			
			gradient.frame = object.bounds
		}
		
		$0.addSubview(pictureImageView)
		pictureImageView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(2*UI.Margins)
		}
		
		return $0
		
	}(UIView())
	private lazy var particulesView:BF_Monsters_Particules_View = {
		
		$0.alpha = 0.0
		return $0
		
	}(BF_Monsters_Particules_View())
	private var pictureViewObserver: NSKeyValueObservation?
	private lazy var pictureImageView:BF_Monsters_ImageView = .init()
	private lazy var rankLabel:BF_Label = {
		
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.45)
		$0.textColor = .white
		$0.font = Fonts.Content.Text.Bold.withSize(Fonts.Size-3)
		$0.layer.cornerRadius = UI.Margins/4
		$0.textAlignment = .center
		$0.contentInsets = .init(horizontal: 2)
		$0.snp.makeConstraints { make in
			make.height.equalTo(1.25*UI.Margins)
		}
		return $0
		
	}(BF_Label())
	private lazy var elementView:BF_Monsters_Element_Button = .init()
	private lazy var nameLabel:BF_Label = {
		
		$0.font = Fonts.Content.Title.H1
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var detailsStackView:UIStackView = { detailsStackView in
		
		detailsStackView.axis = .horizontal
		detailsStackView.alignment = .center
		detailsStackView.distribution = .fillEqually
		
		let stackViewClosure:((BF_Label,String)->Void) = { label, string in
			
			label.font = Fonts.Content.Title.H4
			label.textColor = Colors.Content.Text.withAlphaComponent(0.5)
			label.textAlignment = .center
			
			let keyLabel:BF_Label = .init(string)
			keyLabel.textAlignment = .center
			keyLabel.font = Fonts.Content.Text.Bold.withSize(Fonts.Size - 2)
			
			let stackView:UIStackView = .init(arrangedSubviews: [label,keyLabel])
			stackView.axis = .vertical
			detailsStackView.addArrangedSubview(stackView)
		}
		
		stackViewClosure(genreLabel,String(key: "monsters.genre.label"))
		stackViewClosure(heightLabel,String(key: "monsters.stats.height.label"))
		stackViewClosure(weightLabel,String(key: "monsters.stats.weight.label"))
		
		detailsStackView.arrangedSubviews.forEach({
			
			if $0 != detailsStackView.arrangedSubviews.first {
				
				$0.addLine(position: .leading)
			}
			
			if $0 != detailsStackView.arrangedSubviews.last {
				
				$0.addLine(position: .trailing)
			}
		})
		
		return detailsStackView
		
	}(UIStackView())
	private lazy var genreLabel:BF_Label = .init()
	private lazy var heightLabel:BF_Label = .init()
	private lazy var weightLabel:BF_Label = .init()
	private lazy var descriptionLabel:BF_Label = {
		
		$0.textAlignment = .center
		return $0
		
	}(BF_Label())
	private lazy var hpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "heart")
		$0.color = Colors.Monsters.Stats.Hp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var mpProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "wand.and.stars")
		$0.color = Colors.Monsters.Stats.Mp
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var atkProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "figure.boxing")
		$0.color = Colors.Monsters.Stats.Atk
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var defProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "shield.checkered")
		$0.color = Colors.Monsters.Stats.Def
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var lukProgressView:BF_Monsters_Stat_ProgressView = {
		
		$0.image = UIImage(systemName: "dice.fill")
		$0.color = Colors.Monsters.Stats.Luk
		return $0
		
	}(BF_Monsters_Stat_ProgressView())
	private lazy var elementsStackView:BF_Monsters_Elements_StackView = .init()
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
	public lazy var contentStackView:UIStackView = {
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(horizontal: 2*UI.Margins)
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankLabel,elementView])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		
		let headStackView:UIStackView = .init(arrangedSubviews: [stackView])
		headStackView.axis = .vertical
		headStackView.alignment = .center
		$0.addArrangedSubview(headStackView)
		
		$0.addArrangedSubview(nameLabel)
		$0.addArrangedSubview(detailsStackView)
		$0.addArrangedSubview(descriptionLabel)
		
		let statsLabel:BF_Label = .init(String(key: "monsters.features.label"))
		statsLabel.font = Fonts.Content.Title.H4
		statsLabel.textAlignment = .center
		statsLabel.contentInsets.bottom = UI.Margins/2
		statsLabel.addLine(position: .bottom)
		$0.addArrangedSubview(statsLabel)
		
		let statsStackView:UIStackView = .init(arrangedSubviews: [hpProgressView,mpProgressView,atkProgressView,defProgressView,lukProgressView])
		statsStackView.axis = .vertical
		statsStackView.spacing = UI.Margins/3
		statsStackView.isLayoutMarginsRelativeArrangement = true
		statsStackView.layoutMargins = .init(horizontal: 2*UI.Margins)
		$0.addArrangedSubview(statsStackView)
		
		$0.addArrangedSubview(elementsStackView)
		
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
				
				let alertController:BF_Alert_ViewController = .presentLoading()
				
				self?.monster?.updateProduct(name: name, image: image, { [weak self] error in
					
					alertController.close { [weak self] in
						
						if let error {
							
							BF_Alert_ViewController.present(error)
						}
						else {
							
							let alertController:BF_Alert_ViewController = .presentLoading()
							
							BF_User.current?.monsters.first(where: { $0.uid == self?.monster?.uid })?.product = self?.monster?.product
							BF_User.current?.update({ [weak self] error in
								
								alertController.close { [weak self] in
									
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
					
				})
			}
			alertController.present()
		}
		productButton.isPrimary = false
		
		let informationsStackView:UIStackView = .init(arrangedSubviews: [fightsStackView,dateLabel,productNameLabel,productImageView,productStackView,productButton,mapView])
		informationsStackView.axis = .vertical
		informationsStackView.spacing = 1.5*UI.Margins
		$0.addArrangedSubview(informationsStackView)
		
		return $0
		
	}(UIStackView())
	public lazy var stackView:UIStackView = {
		
		$0.axis = .vertical
		$0.spacing = 1.5*UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		return $0
		
	}(UIStackView(arrangedSubviews: [pictureView,contentStackView]))
	private lazy var scrollView:UIScrollView = {
		
		$0.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview()
		}
		return $0
		
	}(UIScrollView())
	
	deinit {
		
		pictureViewObserver?.invalidate()
	}
	
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
	
	public override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		UIView.animate(5.0) {
			
			self.particulesView.alpha = 1.0
		}
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		scrollView.snp.remakeConstraints { make in
			make.top.equalToSuperview().inset(-view.safeAreaInsets.top)
			make.left.right.bottom.equalToSuperview()
		}
		
		pictureView.snp.remakeConstraints { make in
			make.height.equalTo((UI.Margins*20)+view.safeAreaInsets.top)
		}
		
		pictureImageView.snp.remakeConstraints { make in
			make.top.equalToSuperview().inset((2*UI.Margins)+view.safeAreaInsets.top)
			make.right.bottom.left.equalToSuperview().inset(2*UI.Margins)
		}
	}
	
	private func updateProduct() {
		
		productNameLabel.text = !(monster?.product?.name?.isEmpty ?? true) ? monster?.product?.name : String(key: "monsters.product.label")
		
		productImageView.image = UIImage(named: "empty_palceholder")
		
		if let picture = monster?.product?.picture, !picture.isEmpty {
			
			productImageView.url = picture
		}
	}
}
