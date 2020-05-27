//
//  ItemView.swift
//  ChordSampleApp
//
//  Created by Derrick Ward on 2/26/20.
//  Copyright © 2020 Derrick Ward. All rights reserved.
//

import Foundation
import UIKit

protocol ItemViewDelgate : UIViewController {
    
    func onClose(itemView : ItemView)
}

class ItemView : UIView
{
    @IBOutlet weak var textLabel: UILabel!
    
    weak var delegate : ItemViewDelgate?
    
    @IBAction func onClose(_ sender: Any) {
        isHidden = true
        delegate?.onClose(itemView: self)
    }
    
    static func create(vc: UIViewController, tag : Int,text : String) -> ItemView
    {
        let itemView = Bundle.main.loadNibNamed("ItemView", owner: vc, options: nil)?.first as! ItemView
        itemView.tag = tag
        itemView.delegate = vc as? ItemViewDelgate
        itemView.textLabel.text = text
        return itemView
    }
}
