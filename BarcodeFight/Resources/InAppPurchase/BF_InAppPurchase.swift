//
//  BF_InAppPurchase.swift
//  BarcodeFight
//
//  Created by BLIN Michael on 25/04/2024.
//

import Foundation
import StoreKit

public class BF_InAppPurchase : NSObject {
	
	static let shared:BF_InAppPurchase = .init()
	private var productsRequest: SKProductsRequest?
	private var inAppPurchaseItems:[BF_Item]? {
		
		didSet {
			
			if let productsIdentifiers = inAppPurchaseItems?.compactMap({ $0.inAppPurchaseId }), !productsIdentifiers.isEmpty {
				
				productsRequest = SKProductsRequest(productIdentifiers: Set(productsIdentifiers))
				productsRequest?.delegate = self
				productsRequest?.start()
			}
		}
	}
	public typealias Get_Completion = ((Error?,[(BF_Item?,SKProduct?)]?)->Void)?
	private var productsRequestCompletionHandler:Get_Completion = nil
	public typealias Purchase_Completion = ((SKPaymentTransaction?)->Void)?
	private var purchaseHandler:Purchase_Completion = nil
	
	public override init() {
		
		super.init()
		
		SKPaymentQueue.default().add(self)
	}
	
	public func requestProducts(_ completion:Get_Completion) {
		
		productsRequest?.cancel()
		productsRequestCompletionHandler = completion
		
		BF_Item.get { [weak self] items, error in
				
			self?.inAppPurchaseItems = items?.filter({ !($0.inAppPurchaseId?.isEmpty ?? true) })
		}
	}
	
	public func purchase(_ product:SKProduct, _ purchaseCompletion:Purchase_Completion) {
		
		purchaseHandler = purchaseCompletion
		
		let payment = SKPayment(product: product)
		SKPaymentQueue.default().add(payment)
	}
	
	private func clearRequestAndHandler() {
		
		productsRequest = nil
		inAppPurchaseItems = nil
		productsRequestCompletionHandler = nil
		purchaseHandler = nil
	}
}

extension BF_InAppPurchase: SKProductsRequestDelegate {
	
	public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		
		DispatchQueue.main.async { [weak self] in
			
			self?.productsRequestCompletionHandler?(nil,response.products.compactMap({ inAppPurchaseProduct in
				
				if let item = self?.inAppPurchaseItems?.first(where: { $0.inAppPurchaseId == inAppPurchaseProduct.productIdentifier }) {
					
					return (item,inAppPurchaseProduct)
				}
				
				return nil
			}))
			self?.clearRequestAndHandler()
		}
	}
	
	public func request(_ request: SKRequest, didFailWithError error: Error) {
		
		DispatchQueue.main.async { [weak self] in
			
			self?.productsRequestCompletionHandler?(error, nil)
			self?.clearRequestAndHandler()
		}
	}
}

extension BF_InAppPurchase: SKPaymentTransactionObserver {
	
	public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		
		transactions.forEach({ transaction in
			
			if transaction.transactionState == .purchased {
				
				DispatchQueue.main.async { [weak self] in
					
					self?.purchaseHandler?(transaction)
					self?.clearRequestAndHandler()
				}
				
				SKPaymentQueue.default().finishTransaction(transaction)
			}
		})
	}
}
