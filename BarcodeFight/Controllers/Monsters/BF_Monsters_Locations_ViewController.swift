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
				
				let annotation:BF_Monsters_PointAnnotation = .init()
				annotation.monster = $0
				mapView.addAnnotation(annotation)
			})
			
			mapView.showAnnotations(mapView.annotations, animated: false)
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
		
		view.showPlaceholder(.Loading)
			
		BF_Monster.getAllWithProduct { [weak self] monsters, error in
			
			self?.view.dismissPlaceholder()
				
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					
					self?.launchRequest()
				}
			}
			else {
				
				self?.monsters = monsters
			}
		}
	}
}

extension BF_Monsters_Locations_ViewController : MKMapViewDelegate {
	
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation is MKClusterAnnotation {
			
			let annotationView:BF_Monsters_Cluster_AnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier) as? BF_Monsters_Cluster_AnnotationView ?? BF_Monsters_Cluster_AnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
			annotationView.annotation = annotation
			return annotationView
        }
		else if annotation is BF_Monsters_PointAnnotation {
			
			let annotationView:BF_Monsters_AnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: BF_Monsters_AnnotationView.identifier) as? BF_Monsters_AnnotationView ?? BF_Monsters_AnnotationView(annotation: annotation, reuseIdentifier: BF_Monsters_AnnotationView.identifier)
			annotationView.annotation = annotation
			return annotationView
		}
		
		return nil
	}
	
	public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
		
		(views.filter({ !($0.annotation is MKUserLocation) }) as? [BF_Monsters_AnnotationView])?.forEach({ $0.present() })
	}
	
	public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		
		if let annotationView = view as? BF_Monsters_AnnotationView, let annotation = annotationView.annotation {
			
			mapView.showAnnotations([annotation], animated: true)
			
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
		
		if let clusterView = view as? BF_Monsters_Cluster_AnnotationView, let cluster = clusterView.annotation as? MKClusterAnnotation {
			
			let annotations = cluster.memberAnnotations
			mapView.showAnnotations(annotations, animated: true)
		}
	}
}

