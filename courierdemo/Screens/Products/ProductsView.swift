//
//  ProductsView.swift
//  courierdemo
//
//  Created by Fahreddin Gölcük on 10.12.2021.
//

import Foundation
import UIKit
import Extensions
import Helpers
import RxSwift
import RxCocoa

final class ProductsView: UIView {
    // MARK: - Properties
    private lazy var flowLayout = with(UICollectionViewFlowLayout()) {
        $0.scrollDirection = .vertical
        $0.itemSize = itemSize
        $0.minimumLineSpacing = itemSpacing
        $0.invalidateLayout()
    }
    
    lazy var collectionView = with(
        UICollectionView(
            frame: .zero,
            collectionViewLayout: flowLayout
        )
    ) {
        $0.isScrollEnabled = false
        $0.register(
            ProductItemCell.self,
            forCellWithReuseIdentifier: ProductItemCell.viewIdentifier
        )
    }

    private let isIphone5SizeWidth = UIScreen.main.sizeType == .iPhone4_5
    private let itemSpacing: CGFloat = 15.0

    lazy var stackView = vStack()(
        collectionView
    )
    
    init() {
        super.init(frame: .zero)
        addSubview(stackView)
        stackView.alignFitEdges().activate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base == ProductsView {
    var setHeight: Binder<Int> {
        Binder(base) { target, itemCount in
            target.stackView.alignHeight(target.calculateHeight(itemCount: UInt(itemCount)))
                .activate()
        }
    }
}

// MARK: - Internal Helpers
private extension ProductsView {
    var itemSize: CGSize {
        let totalSpaceSize = isIphone5SizeWidth
        ? (itemSpacing * 2.5)
            : (itemSpacing * 3)
        
        let windowWidth = UIScreen.main.bounds.size.width
        let itemWidth = isIphone5SizeWidth
        ? ((windowWidth - totalSpaceSize) / 1.8)
        : ((windowWidth - totalSpaceSize) / 3.6)
        
        let itemHeight = itemWidth * 2
        let itemSize = CGSize(width: itemWidth, height: itemHeight)
        return itemSize
    }
    
    func calculateHeight(itemCount: UInt) -> CGFloat {
        guard itemCount > 0 else { return 0 }
        let divider = isIphone5SizeWidth ? 2 : 3
        let rowCount = Int(ceil(Double(itemCount) / Double(divider)))
        let totalVerticalSpacing = itemSpacing * CGFloat(rowCount - 1)
        let totalHeight = (CGFloat(rowCount) * itemSize.height) + totalVerticalSpacing
        return totalHeight
    }
}

