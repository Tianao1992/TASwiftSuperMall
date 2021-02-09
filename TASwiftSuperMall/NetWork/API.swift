//
//  API.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/26.
//

import Foundation

let statusHeight =  UIApplication.shared.windows[0].safeAreaInsets.top

let nav_top = statusHeight + 44

let screenWidth = UIScreen.main.bounds.width

let screenHeight = UIScreen.main.bounds.height

struct API {
    static let HomeAPi = "http://152.136.185.210:8000/home/multidata"
}

