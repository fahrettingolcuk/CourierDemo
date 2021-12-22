//
//  CartData.swift
//  courierdemo
//
//  Created by Fahreddin Gölcük on 13.12.2021.
//

import Foundation
import RxSwift
import RxCocoa

struct CartData {
    private let totalItemCount = BehaviorRelay<UInt>(value: 0)
    private let basketInfo = BehaviorRelay<[String: UInt]>(value: [:])
    
    var cartBadgeCount: Observable<UInt> {
        totalItemCount.asObservable()
    }
    
    var cartBadgeCountValue: UInt {
        totalItemCount.value
    }
    
    func updateBadgeCount(with count: UInt) {
        totalItemCount.accept(count)
    }
    
    func setBasketInfo(with info: BasketItemInfo) {
        var basketDict = basketInfo.value
        basketDict[info.productId] = info.quantity
        basketInfo.accept(basketDict)
        print(basketInfo.value)
    }
    
    func isBasketItem(with productId: String) -> Bool {
        basketInfo.value[productId] != nil
    }
    
    func getBasketItemQuantity(with productId: String) -> UInt {
        basketInfo.value[productId] ?? 0
    }
    
}
