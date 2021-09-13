//
//  TabBarViewController.swift
//  Topical Dictionary
//
//  Created by İbrahim Ethem Karalı on 13.03.2019.
//  Copyright © 2019 İbrahim Ethem Karalı. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds
import FBSDKLoginKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, GADInterstitialDelegate {

    var interstitial: GADInterstitial!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitial = createAndLoadInterstitial()
        
        self.delegate = self
        customizeTabBar()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: APIKeys().adUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    //MARK: - Tab Bar Controller
    
    func customizeTabBar() {
        if let items = self.tabBar.items {
            items[0].imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            items[1].imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            items[2].imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.tabBar.unselectedItemTintColor = self.tabBar.tintColor
    }
    
    @objc func addButton() {
        performSegue(withIdentifier: "goToCreateDictionary", sender: self)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // if middle tabbar button is pressed then return false and push the create dictionary view
        if viewController.isKind(of: EmptyButtonViewController.self) {
            performSegue(withIdentifier: "goToCreateDictionary", sender: interstitial)
            
            return false
        }
        
        return true
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCreateDictionary" {
            let destination = segue.destination as! CreateDictionaryViewController
            destination.interstitial = (sender as! GADInterstitial)
        }
    }
    

}

class EmptyButtonViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarController?.tabBar.isHidden = true
    }

}
