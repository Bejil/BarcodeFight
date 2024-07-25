//
//  BF_Monsters_Locations_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/07/2024.
//

import Foundation
import UIKit
import MapKit

extension MKMapView {
	func adjustAnnotations(annotations: [MKAnnotation]) {
		let padding: Double = 10.0 // Distance between annotations
		var adjustedAnnotations = [MKAnnotation]()
		
		for annotation in annotations {
			var adjustedCoordinate = annotation.coordinate
			
				// Loop until we find a non-overlapping position
			while adjustedAnnotations.contains(where: { $0.coordinate.isClose(to: adjustedCoordinate) }) {
				let randomOffset = generateRandomOffset(padding: padding)
				adjustedCoordinate.latitude += randomOffset.latitude * self.region.span.latitudeDelta / self.bounds.size.height
				adjustedCoordinate.longitude += randomOffset.longitude * self.region.span.longitudeDelta / self.bounds.size.width
			}
			
				// Update the annotation's coordinate (you need to have a way to do this)
			if let updatableAnnotation = annotation as? BF_Monster_PointAnnotation {
				updatableAnnotation.coordinate = adjustedCoordinate
			}
			
			adjustedAnnotations.append(annotation)
		}
	}
	
	private func generateRandomOffset(padding: Double) -> (latitude: Double, longitude: Double) {
		let randomDirection = Int.random(in: 0..<4)
		switch randomDirection {
		case 0:
			return (latitude: padding, longitude: 0) // Up
		case 1:
			return (latitude: -padding, longitude: 0) // Down
		case 2:
			return (latitude: 0, longitude: padding) // Right
		case 3:
			return (latitude: 0, longitude: -padding) // Left
		default:
			return (latitude: padding, longitude: 0) // Default case (Up)
		}
	}
}

extension CLLocationCoordinate2D {
	func isClose(to coordinate: CLLocationCoordinate2D, threshold: Double = 0.0001) -> Bool {
		return abs(self.latitude - coordinate.latitude) < threshold && abs(self.longitude - coordinate.longitude) < threshold
	}
}

public class BF_Monsters_Locations_ViewController : BF_ViewController {
	
	public var monsters:[BF_Monster]? {
		
		didSet {
			
			monsters?.forEach({
				
				let annotation:BF_Monster_PointAnnotation = .init()
				annotation.monster = $0
				annotation.coordinate = CLLocationCoordinate2D(latitude: $0.location?.coordinates?.latitude ?? 0.0, longitude: $0.location?.coordinates?.longitude ?? 0.0)
				mapView.addAnnotation(annotation)
			})
			
			mapView.showAnnotations(mapView.annotations, animated: true)
			
			UIApplication.wait(2.0) { [weak self] in
				
				if let annotations = self?.mapView.annotations {
					
					self?.mapView.adjustAnnotations(annotations: annotations)
				}
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
	}
}

extension BF_Monsters_Locations_ViewController : MKMapViewDelegate {
	
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		if annotation is MKUserLocation {
			
			return nil
		}
		
		let annotationView:BF_Monster_AnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: BF_Monster_AnnotationView.identifier) as? BF_Monster_AnnotationView ?? BF_Monster_AnnotationView(annotation: annotation, reuseIdentifier: BF_Monster_AnnotationView.identifier)
		annotationView.annotation = annotation
		return annotationView
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
}

