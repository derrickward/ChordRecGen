//
//  MainViewController.swift
//  ChordSampleApp
//
//  Created by Derrick Ward on 1/11/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation
import SwiftUI

class MainViewController : UIViewController, UITabBarDelegate
{
    var currentViewController : UIViewController!
    var selectedTab : Int = -1
    var chordRecognizerViewController : ChordRecognizerViewController?
    var chordGeneratorViewController : ChordGeneratorViewController?
    
    @IBOutlet weak var panelSelectTabBar: UITabBar!
    @IBOutlet weak var vcContainerView: UIView!
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        panelSelectTabBar.selectedItem = panelSelectTabBar.items?.first!
        showTab(tab: 0)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)
    {
        showTab(tab: item.tag)
    }
    
    private func showTab(tab: Int)
    {
        if tab != selectedTab
        {
            if(currentViewController != nil)
            {
                currentViewController.willMove(toParent: nil)
                currentViewController.view.removeFromSuperview()
                currentViewController.removeFromParent()
            }
            
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            
            switch tab
            {
                case 0:
                    if(chordRecognizerViewController == nil)
                    {
                        chordRecognizerViewController = storyboard.instantiateViewController(withIdentifier: "ChordRecognizerViewController") as? ChordRecognizerViewController
                    }
                    currentViewController = chordRecognizerViewController
                
            case 1:
                    if(chordGeneratorViewController == nil)
                    {
                        chordGeneratorViewController = storyboard.instantiateViewController(withIdentifier: "ChordGeneratorViewController") as? ChordGeneratorViewController
                    }
                    
                    currentViewController = chordGeneratorViewController
           
            default:
                NSLog("no tab selected")
            }
            
            vcContainerView.addSubview(currentViewController.view)
            currentViewController.didMove(toParent: self)
            
            self.selectedTab = tab
            
        }
    }
}
