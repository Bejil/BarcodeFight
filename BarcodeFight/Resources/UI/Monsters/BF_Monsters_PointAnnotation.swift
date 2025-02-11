//
//  BF_Monsters_PointAnnotation.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 22/07/2024.
//

import Foundation
import MapKit

public class BF_Monsters_PointAnnotation : MKPointAnnotation {
	
	public var monster:BF_Monster? {
		
		didSet {
			
			coordinate = CLLocationCoordinate2D(latitude: monster?.location?.coordinates?.latitude ?? 0.0, longitude: monster?.location?.coordinates?.longitude ?? 0.0)
		}
	}
}
