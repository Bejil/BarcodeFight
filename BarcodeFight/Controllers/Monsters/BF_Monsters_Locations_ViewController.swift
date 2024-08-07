//
//  BF_Monsters_Locations_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/07/2024.
//

import Foundation
import UIKit
import MapKit

public class BF_Monsters_Locations_ViewController : BF_ViewController {
	
	public var monsters:[BF_Monster]? {
		
		didSet {
			
			monsters?.forEach({
				
				let annotation:BF_Monster_PointAnnotation = .init()
				annotation.monster = $0
				mapView.addAnnotation(annotation)
			})
			
			mapView.showAnnotations(mapView.annotations, animated: false)
			
			UIApplication.wait { [weak self] in
				
				self?.adjustAnnotations()
				self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
			}
		}
	}
	private lazy var mapView:MKMapView = {
		
		$0.delegate = self
		return $0
		
	}(MKMapView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		view.addSubview(mapView)
		mapView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		mapView.layoutMargins = view.safeAreaInsets
		
		if monsters == nil {
			
			launchRequest()
		}
	}
	
	private func launchRequest() {
		
		let alertController:BF_Alert_ViewController = .presentLoading()
		
		BF_Monster.getAllWithProduct { [weak self] monsters, error in
			
			alertController.close { [weak self] in
				
				if let error {
					
					BF_Alert_ViewController.present(error) { [weak self] in
						
						self?.launchRequest()
					}
				}
				else {
					
					self?.monsters = monsters?.filter({ ($0.product?.name != nil || $0.product?.picture != nil) && $0.location != nil }).sort(.Rank)
				}
			}
		}
	}
	
	private func adjustAnnotations() {
		
		var adjustedAnnotations = [MKAnnotation]()
		
		mapView.annotations.forEach {
			
			var adjustedCoordinate = $0.coordinate
			
			while adjustedAnnotations.contains(where: { isClose(from: $0.coordinate, to: adjustedCoordinate) }) {
				
				let randomCoordinate = generateRandomCoordinate()
				adjustedCoordinate.latitude += randomCoordinate.latitude * mapView.region.span.latitudeDelta / mapView.bounds.size.height
				adjustedCoordinate.longitude += randomCoordinate.longitude * mapView.region.span.longitudeDelta / mapView.bounds.size.width
			}
			
			if let updatableAnnotation = $0 as? BF_Monster_PointAnnotation {
				
				updatableAnnotation.coordinate = adjustedCoordinate
			}
			
			adjustedAnnotations.append($0)
		}
	}
	
	private func generateRandomCoordinate() -> CLLocationCoordinate2D {
		
		let padding = UI.Margins
		let randomDirection = Int.random(in: 0..<4)
		
		switch randomDirection {
		case 0:
			return CLLocationCoordinate2D(latitude: padding, longitude: 0)
		case 1:
			return CLLocationCoordinate2D(latitude: -padding, longitude: 0)
		case 2:
			return CLLocationCoordinate2D(latitude: 0, longitude: padding)
		case 3:
			return CLLocationCoordinate2D(latitude: 0, longitude: -padding)
		default:
			return CLLocationCoordinate2D(latitude: padding, longitude: 0)
		}
	}
	
	private func isClose(from fromCoordinate: CLLocationCoordinate2D, to toCoordinate: CLLocationCoordinate2D, threshold: Double = 0.0001) -> Bool {
		
		return abs(fromCoordinate.latitude - toCoordinate.latitude) < threshold && abs(fromCoordinate.longitude - toCoordinate.longitude) < threshold
	}
}

extension BF_Monsters_Locations_ViewController : MKMapViewDelegate {
	
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation is MKClusterAnnotation {
			
			let annotationView:BF_Monster_Cluster_AnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) as? BF_Monster_Cluster_AnnotationView ?? BF_Monster_Cluster_AnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
			annotationView.annotation = annotation
			return annotationView
        }
		else if annotation is BF_Monster_PointAnnotation {
			
			let annotationView:BF_Monster_AnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: BF_Monster_AnnotationView.identifier) as? BF_Monster_AnnotationView ?? BF_Monster_AnnotationView(annotation: annotation, reuseIdentifier: BF_Monster_AnnotationView.identifier)
			annotationView.annotation = annotation
			return annotationView
		}
		
		return nil
	}
	
	public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		
		(views.filter({ !($0.annotation is MKUserLocation) }) as? [BF_Monster_AnnotationView])?.forEach({ $0.present() })
	}
	
	public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
		
		if let annotationView = view as? BF_Monster_AnnotationView {
			
			let viewController:BF_Monsters_Details_ViewController = .init()
			viewController.monster = annotationView.monster
			UI.MainController.present(viewController, animated: true)
		}
	}
	
	public func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [any MKAnnotation]) -> MKClusterAnnotation {
		
		let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
		cluster.title = ["\(memberAnnotations.count)",String(key: "monsters.products.callout.title")].joined(separator: " ")
		cluster.subtitle = String(key: "monsters.products.callout.subtitle")
		return cluster
	}
	
	public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if let clusterView = view as? BF_Monster_Cluster_AnnotationView, let cluster = clusterView.annotation as? MKClusterAnnotation {
			
			let annotations = cluster.memberAnnotations
			mapView.showAnnotations(annotations, animated: true)
		}
	}
}

