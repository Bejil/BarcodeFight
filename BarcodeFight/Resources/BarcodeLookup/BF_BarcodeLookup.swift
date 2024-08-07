//
//  BF_BarcodeLookup.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 18/07/2024.
//

import Foundation
import UIKit
import WebKit

public class BF_BarcodeLookup : NSObject {
	
	public static let shared:BF_BarcodeLookup = .init()
	
	public var barcode:String?
	public var completion:((BF_Monster.Product?)->Void)?
	private var webView:WKWebView?
	private var urlString:String = "https://www.barcodelookup.com/"
	
	public func search(_ completion:((BF_Monster.Product?)->Void)?) {
		
		self.completion = completion
		
		webView = .init()
		
		if let webView, let url = URL(string: urlString) {
			
			webView.navigationDelegate = self
			
			let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
			window?.addSubview(webView)
			
			let request = URLRequest(url: url)
			webView.load(request)
		}
	}
}

extension BF_BarcodeLookup : WKNavigationDelegate {
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		
		if webView.url?.absoluteString == urlString {
			
			let javaScriptString = """
  document.querySelector('.search-bar input[name="search-input"]').value = \(barcode ?? "");
  document.querySelector('.search-bar button[type="submit"]').click();
  """
			
			webView.evaluateJavaScript(javaScriptString)
		}
		else if webView.url?.absoluteString == urlString + (barcode ?? "") {
			
			let javaScriptString = """
  (function() {
   return {name: document.querySelector('.product-details h4').textContent, picture: document.querySelector('#largeProductImage img').src};
  })();
  """
			webView.evaluateJavaScript(javaScriptString) { [weak self] result, _ in
				
				let resultDict = result as? [String: String]
				
				let product:BF_Monster.Product = .init()
				product.name = resultDict?["name"]?.trimmingCharacters(in: .whitespacesAndNewlines)
				product.picture = resultDict?["picture"]
				self?.completion?(product)
				
				self?.barcode = nil
				self?.completion = nil
				
				webView.removeFromSuperview()
			}
		}
	}
}
