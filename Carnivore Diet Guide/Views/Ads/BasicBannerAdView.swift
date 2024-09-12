//
//  BasicBannerAdView.swift
//  Carnivore Diet Guide
//
//  Created by Jason Vance on 9/12/24.
//

import SwiftUI
import GoogleMobileAds

struct BasicBannerAdView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = BannerAdViewController
    
    func makeUIViewController(context: Context) -> BannerAdViewController {
        BannerAdViewController()
    }
    
    func updateUIViewController(_ bannerAdViewController: BannerAdViewController, context: Context) { }
}

class BannerAdViewController: UIViewController {
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width
        
        let adSize = GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView = GADBannerView(adSize: adSize)
        
        addBannerViewToView(bannerView)
        
        //  Set the ad unit ID and view controller that contains the GADBannerView.
#if DEBUG
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
#else
        bannerView.adUnitID = "ca-app-pub-1475400719226569/2816644370"
#endif
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints([
            NSLayoutConstraint(
                item: bannerView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .top,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: bannerView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: bannerView,
                attribute: .left,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .left,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: bannerView,
                attribute: .right,
                relatedBy: .equal,
                toItem: view.safeAreaLayoutGuide,
                attribute: .right,
                multiplier: 1,
                constant: 0
            )
        ])
    }
}
