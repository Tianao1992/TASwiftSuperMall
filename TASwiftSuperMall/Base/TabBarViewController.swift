//
//  TabBarViewController.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/27.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setValue(TabBar(), forKeyPath: "tabBar")
        tabBar.barTintColor = UIColor.white
        addChild(title: "首页",image: "home",selectImge: "home_active",type: HomeViewController.self)
        addChild(title: "分类",image: "category",selectImge: "category_active",type: CategroyViewController.self)
        addChild(title: "购物车",image: "shopcart",selectImge: "shopcart_active",type: ShopCartViewController.self)
        addChild(title: "我的",image: "profile",selectImge: "profile_active",type: ProfileViewController.self)
    }
     func addChild(title: String, image: String, selectImge:String, type: UIViewController.Type){
        let child = NavigationViewController(rootViewController: type.init())
        child.title = title
        child.tabBarItem.image = UIImage(named: image)
        child.tabBarItem.selectedImage = UIImage(named: selectImge)
        child.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black
        ], for: .selected)
        addChild(child)
    }
}

