//
//  GameViewController.swift
//  BinhGame
//
//  Created by Binh Le on 7/10/15.
//  Copyright (c) 2015 Le Developers. All rights reserved.
//


import UIKit
import SpriteKit
import AVFoundation
import GoogleMobileAds
import GameKit

class GameViewController: UIViewController {
    
    var currentGame: GameScene!

    //@IBOutlet weak var adButton: UIButton!
    //@IBOutlet weak var bannerView: GADBannerView!
    //var interstitial: GADInterstitial!
    var done = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //self.interstitial = self.createAndLoadAd()
        
        //bannerView.adUnitID = "ca-app-pub-2540314652045992/6934737865"
        //bannerView.rootViewController = self
        //bannerView.setSize(kGADAdSizeSmartBannerPortrait)
        //var request: GADRequest = GADRequest()
        //bannerView.loadRequest(request)
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        //skView.showsFPS = true
        //skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        currentGame = scene
        scene.viewController = self
    }
    
    /*@IBAction func adButton(sender: AnyObject) {
        if(self.interstitial.isReady && done == false){
            done = true
            adButton.hidden = true
            self.interstitial.presentFromRootViewController(self)
            self.interstitial = self.createAndLoadAd()
        }
    }
    
    func createAndLoadAd() -> GADInterstitial{
        let ad = GADInterstitial(adUnitID: "ca-app-pub-2540314652045992/6051603869")
        let request: GADRequest = GADRequest()
        //request.testDevices = ["b08bf949370649bc0ecae23cba6f9c7c"]
        ad.loadRequest(request)
        return ad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hidesBanner (banner: GADBannerView!) {
        bannerView.hidden = true
    }
    
    func showsBanner (banner: GADBannerView!) {
        bannerView.hidden = false
    }*/
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}