//
//  LoginViewController.swift
//  CoffeeShop
//
//  Created by Göktuğ Gümüş on 23.09.2018.
//  Copyright © 2018 Göktuğ Gümüş. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var emailTextfield: UITextField!
    @IBOutlet private weak var passwordTextfield: UITextField!
    @IBOutlet private weak var logInButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emailValid = emailTextfield
            .rx
            .text // textine işlem yaptırıyorum
            .orEmpty // gerçekten string bir karakter var mı null ve ya boş mu diye kontrol ediyorum
            .throttle(throttleInterval, scheduler: MainScheduler.instance)// Bu metod bir input olduğunda 0.1 saniye bekliyor tekrar inputu kontrol ediyor varsa üzerine ekliyor eğer 0.1 saniye sonra bir input görmezse son halini akışa aktarıyor
            .map({ self.validateEmail(with: $0) }) // gerçekten email girilmişmi diye kontrol ediyoruz
            .debug("emailvalid", trimOutput: true)// debug modunu alıyor print ediyoruz durumu
            
            .share(replay: 1)// 2 tane textfield varsa 2 sinide dönüyor ona göre sonuç veriyor
        
        let passValid = passwordTextfield
        .rx
        .text
        .orEmpty
        .map({ $0.count >= 6 })
        .share(replay: 1)
        
        // CombineLatest rx swiftin birleştirme operatörlerinden biridir Bunun sayesinde aynı tipte olan birden fazla Observable değişkenini tek bir Observable değişkeni altında toplayabiliyoruz
        let everythingValid = Observable
        .combineLatest(passValid, passValid) { $0 && $1 }
        .debug("everythingValid", trimOutput: true)
        .share(replay: 1)
        
        everythingValid
            .bind(to: logInButton.rx.isEnabled) // Observable değişkenlerini bir birine bağlamamıza olanak tanır mesela burada login buttonun isEnabled metodunu bir Observable değişkeni olarak döndürür
            .disposed(by: disposeBag) // bind(to: ) metodu bize disposable tipinde bir değişken dönrür ve class init olduğunda biriken Observabledan düzgün bir şekilde kurtulmamazı sağlar
        
    }
    
    private func validateEmail(with email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@([A-Za-z0-9.-]{2,64})+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        
        return predicate.evaluate(with: email)
    }
    
    @IBAction private func logInButtonPressed() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryboard.instantiateInitialViewController()!
        
        UIApplication.changeRoot(with: initialViewController)
    }
}
