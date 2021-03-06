//
//  LoginViewModel.swift
//  courierdemo
//
//  Created by Fahreddin Gölcük on 8.11.2021.
//

import Foundation
import RxCocoa
import RxSwift
import RxSwiftExtensions
import AppEnvironment
import Entities

struct LoginViewModelInput {
    var viewDidLoad: Observable<Void> = .never()
    var loginApi: LoginServiceProtocol
    var email: Observable<String> = .never()
    var password: Observable<String> = .never()
    var buttonTapped: Observable<Void> = .never()
}

struct LoginViewModelOutput {
    let isLoading: Driver<Bool>
    let verifyButton: Driver<Bool>
    let loginButtonTapped: Driver<UserResponse>
}

typealias LoginViewModel = (LoginViewModelInput) -> LoginViewModelOutput

func loginViewModel(input: LoginViewModelInput) -> LoginViewModelOutput {
    let activity = ActivityIndicator()
    
    let credential = Observable.combineLatest(input.email, input.password)
    
    // MARK: - FavoriteProductList Response
    let (loginResponse, _) =
    Observable.merge(input.viewDidLoad.skip(1), input.buttonTapped)
        .withLatestFrom(credential)
        .apiCall(activity) { credential -> Single<UserResponse> in
            input.loginApi.login(credential: LoginRequest(email: credential.0, password: credential.1))
                .do(onSuccess: {
                    Current.userName.accept($0.user.name)
                    Current.userId.accept($0.user.id)
                })
        }

    return LoginViewModelOutput(
        isLoading: activity.asDriver(),
        verifyButton: verifyButton(input.email, input.password),
        loginButtonTapped: loginResponse
    )
}

private func verifyButton(
    _ email: Observable<String>,
    _ password: Observable<String>
) -> Driver<Bool> {
    Observable
        .combineLatest(email, password)
        .map { !$0.0.isEmpty && !$0.1.isEmpty }
        .asDriver(onErrorDriveWith: .never())
}

private func loginButtonApprove(
    _ inputs: LoginViewModelInput,
    _ indicator: ActivityIndicator,
    _ buttonTapped: Observable<Void>
) -> (Driver<UserResponse>, Driver<Error>) {
    return buttonTapped
        .skip(1)
        .apiCall(indicator) { _ -> Single<UserResponse> in
            inputs.loginApi.login(credential: LoginRequest(email: "", password: ""))
        }
}

