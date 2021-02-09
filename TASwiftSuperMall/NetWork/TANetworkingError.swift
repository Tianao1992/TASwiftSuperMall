//
//  TANetworkingError.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/26.
//

import UIKit

public class TANetworkingError: NSObject {
  @objc var code = -1
  @objc var localizedDescription: String
  init(_ code: Int,localizedDescription: String ) {
        self.code = code
        self.localizedDescription = localizedDescription
        super.init()
    }
}

