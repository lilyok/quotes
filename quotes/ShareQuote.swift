//
//  ShareQuote.swift
//  quotes
//
//  Created by Liliia Ivanova on 24.05.2021.
//

import SwiftUI

func showShareActivity(msg:String?, image:UIImage?, url:String?, sourceRect:CGRect?){
    var objectsToShare = [AnyObject]()
    
    if let url = url {
        objectsToShare = [url as AnyObject]
    }
    
    if let image = image {
        objectsToShare = [image as AnyObject]
    }
    
    if let msg = msg {
        objectsToShare = [msg as AnyObject]
    }
    
    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
    activityVC.modalPresentationStyle = .popover
    activityVC.popoverPresentationController?.sourceView = topViewController().view
    if let sourceRect = sourceRect {
        activityVC.popoverPresentationController?.sourceRect = sourceRect
    }
    
    topViewController().present(activityVC, animated: true, completion: nil)
}

func topViewController()-> UIViewController{
    var topViewController:UIViewController = UIApplication.shared.windows.first { $0.isKeyWindow }!.rootViewController!
    
    while ((topViewController.presentedViewController) != nil) {
        topViewController = topViewController.presentedViewController!;
    }
    
    return topViewController
}

func takeScreenshot() -> UIImage?{
    
    var screenshotImage :UIImage?
    let layer = UIApplication.shared.windows.first { $0.isKeyWindow }!.layer
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    guard let context = UIGraphicsGetCurrentContext() else {return nil}
    layer.render(in:context)
    screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return screenshotImage
}
