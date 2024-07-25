//
//  BF_Scanner_ViewController.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 30/04/2024.
//

import AVFoundation
import UIKit

public class BF_Scanner_ViewController: BF_ViewController {
	
	public enum Style {
		
		case Barcode
		case Qr
	}
	
	public var style:Style? {
		
		didSet {
			
			if oldValue != nil {
				
				metadataOutput.metadataObjectTypes = style == .Qr ? [.qr] : [.ean8, .ean13, .pdf417]
				titleLabel.text = String(key: style == .Qr ? "scanner.title.qr" : "scanner.title.barcode")
				imageView.image = UIImage(named: style == .Qr ? "qrcode_icon" : "barcode_icon")
				imageView.snp.remakeConstraints { make in
					
					if style == .Qr {
						
						make.height.equalToSuperview().multipliedBy(0.5)
					}
					else {
						
						make.height.equalTo(100)
					}
				}
			}
		}
	}
	public var handler:((String?)->Void)?
	private var previewLayer:AVCaptureVideoPreviewLayer = .init()
	private lazy var imageView:BF_ImageView = {
		
		$0.contentMode = .scaleAspectFit
		$0.alpha = 0.1
		return $0
		
	}(BF_ImageView(image: UIImage(named: style == .Qr ? "qrcode_icon" : "barcode_icon")))
	private lazy var dimView:UIVisualEffectView = { view in
		
		view.alpha = 0.85
		
		view.contentView.addSubview(titleLabel)
		titleLabel.snp.makeConstraints { make in
			make.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(2*UI.Margins)
		}
		
		return view
		
	}(UIVisualEffectView(effect: UIBlurEffect.init(style: .dark)))
	private lazy var titleLabel:BF_Label = {
		
		$0.font = Fonts.Navigation.Title.Large
		$0.textColor = Colors.Navigation.Title
		$0.textAlignment = .center
		return $0
		
	}(BF_Label(String(key: style == .Qr ? "scanner.title.qr" : "scanner.title.barcode")))
	private lazy var animatedView:UIView = {
		
		$0.backgroundColor = Colors.Secondary
		$0.layer.cornerRadius = (UI.Margins/5)/2
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins/5)
		}
		return $0
		
	}(UIView())
	private lazy var metadataOutput:AVCaptureMetadataOutput = .init()
	private lazy var captureSession: AVCaptureSession = {
		
		if let videoCaptureDevice = AVCaptureDevice.default(for: .video), let videoInput: AVCaptureDeviceInput = try?AVCaptureDeviceInput(device: videoCaptureDevice) {
			
			if ($0.canAddInput(videoInput)) {
				
				$0.addInput(videoInput)
			}
		}
		
		if ($0.canAddOutput(metadataOutput)) {
			
			$0.addOutput(metadataOutput)
			
			metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			metadataOutput.metadataObjectTypes = style == .Qr ? [.qr] : [.ean8, .ean13, .pdf417]
		}
		
		return $0
		
	}(AVCaptureSession())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		
		previewLayer.session = captureSession
		previewLayer.frame = view.layer.bounds
		previewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(previewLayer)
		
		view.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.center.equalToSuperview()
			make.width.equalToSuperview().multipliedBy(0.5)
			
			if style == .Qr {
				
				make.height.equalToSuperview().multipliedBy(0.5)
			}
			else {
				
				make.height.equalTo(100)
			}
		}
		
		view.addSubview(dimView)
		dimView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		view.addSubview(animatedView)
		animatedView.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
		}
		
		view.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] sender in
			
			let location = sender.location(in: sender.view)
			
			if let devicePoint = self?.previewLayer.captureDevicePointConverted(fromLayerPoint: location), let device = self?.captureSession.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device, device.isFocusPointOfInterestSupported || device.isExposurePointOfInterestSupported {
				
				try?device.lockForConfiguration()
				
				if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
					
					device.focusPointOfInterest = devicePoint
					device.focusMode = .autoFocus
				}
				
				if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
					
					device.exposurePointOfInterest = devicePoint
					device.exposureMode = .autoExpose
				}
				
				device.isSubjectAreaChangeMonitoringEnabled = true
				
				device.unlockForConfiguration()
			}
			
			let effectContainerView:UIView = .init()
			effectContainerView.isUserInteractionEnabled = false
			effectContainerView.clipsToBounds = true
			sender.view?.addSubview(effectContainerView)
			
			effectContainerView.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
			
			sender.view?.layoutIfNeeded()
			
			let view:UIView = .init()
			view.backgroundColor = .white
			view.alpha = 0.25
			effectContainerView.addSubview(view)
			
			view.snp.makeConstraints { make in
				make.width.height.equalTo(0)
				make.center.equalTo(location)
			}
			
			let radius = max(effectContainerView.frame.size.width,effectContainerView.frame.size.height)
			
			UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
				
				view.layer.cornerRadius = radius
				
				view.snp.updateConstraints { make in
					
					make.width.height.equalTo(2*radius)
				}
				
				view.layoutIfNeeded()
				view.alpha = 0.0
				
			} completion: { _ in
				
				effectContainerView.removeFromSuperview()
			}
		}))
		
		DispatchQueue.global(qos: .background).async { [weak self] in
			
			self?.captureSession.startRunning()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		let maskLayer = CAShapeLayer()
		maskLayer.frame = dimView.bounds
		maskLayer.fillRule = .evenOdd
		
		let path = UIBezierPath(rect: dimView.bounds)
		
		let width = view.frame.size.width*0.75
		let height = style == .Qr ? width : 150.0
		
		let frame = CGRect(x: view.center.x-(width/2), y: view.center.y-(height/2), width: width, height: height)
		
		let holePath = UIBezierPath(roundedRect: frame, cornerRadius: UI.Margins)
		
		path.append(holePath)
		
		maskLayer.path = path.cgPath
		maskLayer.fillColor = UIColor.black.cgColor
		
		dimView.layer.mask = maskLayer
		
		metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: frame)
		
		animatedView.snp.makeConstraints { make in
			make.width.equalTo(frame.size.width-(2*UI.Margins))
			make.top.equalTo(frame.origin.y+UI.Margins)
		}
		
		animatedView.layer.removeAllAnimations()
		
		let animation = CABasicAnimation(keyPath: "position.y")
		animation.repeatCount = .infinity
		animation.autoreverses = true
		animation.duration = 1.5
		animation.toValue = frame.maxY-UI.Margins
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		animatedView.layer.add(animation, forKey: "animatePosition")
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		if !captureSession.isRunning {
			
			captureSession.startRunning()
		}
	}
	
	public override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		if captureSession.isRunning {
			
			captureSession.stopRunning()
		}
	}
}

extension BF_Scanner_ViewController : AVCaptureMetadataOutputObjectsDelegate {
	
	public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		
		captureSession.stopRunning()
		
		if let metadataObject = metadataObjects.first,
		   let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
		   let stringValue = readableObject.stringValue {
			
			UIApplication.feedBack(.Success)
			
			dismiss(animated: true, completion: { [weak self] in
				
				self?.handler?(stringValue)
			})
		}
	}
}
