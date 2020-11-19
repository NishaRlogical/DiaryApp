//
//  ViewExtension.swift
//  DiaryApp
//
//  Created by rlogical-dev-11 on 18/11/20.
//

import Foundation
import UIKit


class shadowView: UIView {
    override func draw(_ rect: CGRect) {
        self.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        
    }
}
