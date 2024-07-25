//
//  UIImage_Extension.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 07/08/2023.
//

import Foundation
import UIKit

extension UIImage {
	
	public var noir:UIImage? {
		
		let context = CIContext(options: nil)
		guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
		currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
		
		if let output = currentFilter.outputImage,
		   
			let cgImage = context.createCGImage(output, from: output.extent) {
			return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
		}
		
		return nil
	}
	
	public func png() -> Data? {
		
		return flattened().pngData()
	}
	
	private func flattened() -> UIImage {
		
		if imageOrientation == .up { return self }
		let format = imageRendererFormat
		return UIGraphicsImageRenderer(size: size, format: format).image { _ in draw(at: .zero) }
	}
	
	func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
			
		let widthRatio = targetSize.width / size.width
		let heightRatio = targetSize.height / size.height
		let scaleFactor = min(widthRatio, heightRatio)
		let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
		let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
		let scaledImage = renderer.image { _ in
			
			self.draw(in: CGRect(origin: .zero,size: scaledImageSize))
		}
		return scaledImage
	}
	
	func resize(_ width:CGFloat) -> UIImage? {
		
		let scale = width/size.width
		let newHeight = size.height*scale
		UIGraphicsBeginImageContextWithOptions(.init(width: width, height: newHeight), false, UIScreen.main.scale)
		
		let context = UIGraphicsGetCurrentContext()
		context?.setShouldAntialias(false)
		context?.interpolationQuality = .none
		
		draw(in: .init(origin: .zero, size: .init(width: width, height: newHeight)))
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}
