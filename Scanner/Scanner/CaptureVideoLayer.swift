//
//  CaptureVideoLayer.swift
//  Scanner
//
//  Created by pfl on 15/5/13.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import AVFoundation
import Foundation

class CaptureVideoLayer: AVCaptureVideoPreviewLayer {

    override func copy() -> AnyObject {
        
        
        return CaptureVideoLayer()
    }
    
}


