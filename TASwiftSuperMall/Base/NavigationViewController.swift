//
//  NavigationViewController.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/27.
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 100, green: 100, blue: 100, alpha: 0.3)
        navigationBar.clipsToBounds = false
    }
    //重写跳转
    override func pushViewController(_ viewController: UIViewController, animated: Bool)
       {
           if children.count > 0 {
               viewController.hidesBottomBarWhenPushed = true
           }
           let image = UIImage(named: "navBar_black_back")
           UINavigationBar.appearance().backIndicatorImage = image
           UINavigationBar.appearance().backIndicatorTransitionMaskImage = image
           let backButtonItem = UIBarButtonItem(title: nil, style: .done, target: nil, action: nil)
           visibleViewController?.navigationItem.backBarButtonItem = backButtonItem
        
           super.pushViewController(viewController, animated: animated)
       }
    
}
