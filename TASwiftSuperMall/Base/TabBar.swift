//
//  TabBar.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/27.
//

import UIKit

class TabBar: UITabBar {

    override func layoutSubviews() {
        super.layoutSubviews()
        for item in items! {
            item.imageInsets = UIEdgeInsets(top:5,left: 8,bottom: 5,right: 8)
        }
    }

}
