//
//  UIImageView.swift
//  Kamaemon
//
//  Created by mad2 on 1/2/22.
//

import Foundation
extension UIImageView {
  public func maskCircle(anyImage: UIImage) {
    self.contentMode = UIViewContentMode.ScaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true

   // make square(* must to make circle),
   // resize(reduce the kilobyte) and
   // fix rotation.
   self.image = anyImage
  }
}
