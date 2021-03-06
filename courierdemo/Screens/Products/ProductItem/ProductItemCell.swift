//
//  ProductItemCell.swift
//  courierdemo
//
//  Created by Fahreddin Gölcük on 10.12.2021.
//

import UIKit
import RxSwift
import Helpers
import Extensions

final class ProductItemCell: UICollectionViewCell {
    private(set) var bag = DisposeBag()

    let (increaseButtonTapObserver, increaseButtonTappedEvent) = Observable<Void>.pipe()
    let (decreaseButtonTapObserver, decreaseButtonTappedEvent) = Observable<Void>.pipe()
    let (plusButtonTapObserver, plusButtonTappedEvent) = Observable<Void>.pipe()
    
    var editingAmountView = ProductItemAmountView()
    
    private lazy var addProductButton = with(UIButton(type: .custom)) {
        let image = UIImage(named: "add_to_cart")
        $0.setImage(image, for: .normal)
        $0.isAccessibilityElement = false
    }
    
    private lazy var containerView = with(UIView()) {
        $0.layer.cornerRadius = 15.0
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor.Theme.secondary
    }
    
    private var image = with(UIImageView()) {
        $0.contentMode = .scaleAspectFit
    }
    
    private let title = with(UILabel()) {
        $0.font = UIFont.Fonts.boldSmall
        $0.textColor = UIColor.Theme.primary
        $0.textAlignment = .center
        $0.numberOfLines = 2
        
    }

    private let calorie = with(UILabel()) {
        $0.font = UIFont.Fonts.thinSmall
        $0.textColor = UIColor.Theme.title
        $0.textAlignment = .center
    }

    private let price = with(UILabel()) {
        $0.font = UIFont.Fonts.boldSmall
        $0.textColor = UIColor.Theme.primary
        $0.textAlignment = .center
    }
        
    lazy var stackView = vStack(
    space: 8
    )(
        image,
        title,
        calorie,
        price
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        
        editingAmountView.isAccessibilityElement = false
        
        let frameX = 5
        let width = 80
        
        editingAmountView.frame = CGRect(
            x: frameX,
            y: 5,
            width: width,
            height: (width / 3)
        )
        editingAmountView.isHidden = true
        
        [
           stackView,
           editingAmountView
        ]
        .forEach(containerView.addSubview(_:))
        addSubview(addProductButton)
        [
            stackView.alignFitEdges(),
            containerView.alignFitEdges(),
            [
                image.alignHeight(self.bounds.height * 0.4)
            ]
        ]
        .flatMap { $0 }
        .activate()

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        isAccessibilityElement = true
        accessibilityTraits = .none
        
        bag.insert(
            addProductButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.plusButtonTapObserver.onNext(())
                }),
            editingAmountView.rightButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.increaseButtonTapObserver.onNext(())
                }),
            editingAmountView.leftButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.decreaseButtonTapObserver.onNext(())
                })
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout SubViews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let frameX = bounds.width - 32.0
        addProductButton.bounds = CGRect(
            x: frameX,
            y: 0,
            width: 32.0,
            height: 32.0
        )
        addProductButton.center = CGPoint(
            x: self.bounds.width - 12.0,
            y: 16.0
        )
    }
}

// MARK: - Populate UI
extension ProductItemCell {
    var populate: Binder<Product> {
        Binder(self) { target, datasource in
            target.title.text = datasource.name
            target.calorie.text = "\(datasource.calorie) cal"
            target.price.text = "$ \(datasource.price)"
            target.image.image = UIImage(named: datasource.image)
            target.editingAmountView.quantityLabel.text = "\(Current.cartData.getBasketItemQuantity(with: datasource._id))"
        }
    }
    
    var updateView: Binder<ProductItemEditViewDatasource> {
        Binder(self) { target, datasource in
            target.editingAmountView.quantityLabel.text = "\(datasource.quantity)"
            target.editingAmountView.leftButton.setImage(UIImage(named: datasource.leftButtonImage), for: .normal)
            if(datasource.showEditView) {
                target.setAmountView()
            } else {
                target.setAddView()
            }
        }
    }
    
    //MARK: - when change the category, trigger bag and remove subscribe contents.
    var bagClear: Binder<Void> {
        Binder(self) { target, _  in
            target.bag = DisposeBag()
            target.addProductButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.plusButtonTapObserver.onNext(())
                }).disposed(by: target.bag)
            target.bag.insert(
                target.editingAmountView.rightButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.increaseButtonTapObserver.onNext(())
                    }),
                target.editingAmountView.leftButton.rx.tap
                    .subscribe(onNext: { [weak self] in
                        self?.decreaseButtonTapObserver.onNext(())
                    })
            )
        }
    }
    
}

extension ProductItemCell {
    func setAmountView() {
        addProductButton.isHidden = true
        editingAmountView.isHidden = false
    }
    
    func setAddView() {
        addProductButton.isHidden = false
        editingAmountView.isHidden = true
    }
}
