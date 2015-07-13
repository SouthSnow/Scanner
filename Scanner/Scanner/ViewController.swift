//
//  ViewController.swift
//  Scanner
//
//  Created by pfl on 15/5/13.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit
import AVFoundation

let square = [CGPoint(x: kLineMinX,y: kLineMinY),//0
    CGPoint(x: kLineMinX,y: kLineMinY),//1
    CGPoint(x: kLineMinX,y: 224),//2
    CGPoint(x: kLineMinX,y: kLineMinY+kReaderHeight-kSquareWidth),//3
    CGPoint(x: kLineMinX,y: kLineMinY+kReaderHeight-2),//4
    CGPoint(x: 100,y: 382),//5
    CGPoint(x: kLineMinX + kReaderWidth - kSquareWidth,y: kLineMinY+kReaderHeight-2),//6
    CGPoint(x: kLineMinX + kReaderWidth - 2,y: kLineMinY+kReaderHeight-kSquareWidth),//7
    CGPoint(x: 220,y: 344),//8
    CGPoint(x: kLineMinX + kReaderWidth - 2,y: kLineMinY),//9
    CGPoint(x: kLineMinX + kReaderWidth - kSquareWidth,y: kLineMinY),//10
    CGPoint(x: 220,y: kLineMinY),//11
]

let kReaderWidth: CGFloat = 200
let kReaderHeight: CGFloat = 200
let kAlpha: CGFloat = 0.5
let kSquareWidth: CGFloat = 20
let kDeviceWidth: CGFloat = UIScreen.mainScreen().bounds.width
let kDeviceHeigth: CGFloat = UIScreen.mainScreen().bounds.height
let kLineMinX: CGFloat = kDeviceWidth/2 - kReaderWidth/2
let kLineMinY: CGFloat = kDeviceHeigth/2 - kReaderHeight/2 - 50

let filenameExtension = "txt"

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: CaptureVideoLayer?
    var qrCodeFrameView: UIView?
    var messageLabel: UILabel?
    var scanLabel: UILabel? = UILabel()
    var isStopScan: Bool? = false
    var isAnimation: Bool? = false
    var managedObjectContext: NSManagedObjectContext?
    var fetchResultsController: NSFetchedResultsController?
    var metadataQuery: NSMetadataQuery?
    var documents: NSMutableArray?
    var stack: PersistentStack!
    var coverView: UIView?{
        didSet
        {
            coverView?.backgroundColor = UIColor.blackColor()
            coverView?.layer.opacity = 0.6
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "扫描/查询"
        self.navigationController?.navigationBar.barTintColor = UIColor.greenColor()//(red: 0.863, green: 0.243, blue: 0.051, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫描历史", style: UIBarButtonItemStyle.Plain, target: self, action: "showDetail")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "相册", style: UIBarButtonItemStyle.Plain, target: self, action: "createThirdScaner")
        
        createSystemSCaner()
        
        startRuning()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//            startRuning()
        
//        println(fetchResultsController?.delegate.self)
        
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopRuning()

    }
    
    
    func setupAndStartQuery()
    {
        if let metadataQuery = metadataQuery
        {
            
        }
        else
        {
            metadataQuery = NSMetadataQuery()
            metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            let filePattern = String(format: "*.%@", filenameExtension)
            metadataQuery?.predicate = NSPredicate(format: "%K LIKE %@", filePattern)
            metadataQuery?.startQuery()
            
            // MARK: register notification
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "processFile:", name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "processFile:", name: NSMetadataQueryDidUpdateNotification, object: nil)
        }
        
    }
    
    func processFile(notifition: NSNotification)
    {
        
        metadataQuery?.disableUpdates()
        
        documents = NSMutableArray()
        let results = metadataQuery?.results
        var fileItemArr: NSMutableArray = NSMutableArray()
        for metadataItem in results as! [NSMetadataItem]
        {
            let fileURL = metadataItem.valueForAttribute(NSMetadataItemURLKey) as! NSURL
            var aBool: Bool? = false
            fileURL.getResourceValue(nil, forKey: NSURLIsHiddenKey, error: nil)
            fileItemArr.addObject(fileURL)
        }
        
        documents?.removeAllObjects()
        documents?.addObjectsFromArray(fileItemArr as [AnyObject])
        
        metadataQuery?.enableUpdates()
        
    }
    
    
    func createSystemSCaner()
    {
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error: NSError?
        var captureInput: AnyObject? = AVCaptureDeviceInput.deviceInputWithDevice(captureDevice, error: &error)
        if error != nil
        {
            println(error?.localizedDescription)
            return
        }
        
        captureSession = AVCaptureSession()
        if captureSession!.canSetSessionPreset(AVCaptureSessionPreset1920x1080)
        {
            captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        }else if captureSession!.canSetSessionPreset(AVCaptureSessionPreset640x480)
        {
            captureSession?.sessionPreset = AVCaptureSessionPreset640x480
        }
        
        if captureSession!.canAddInput(captureInput as! AVCaptureInput)
        {
            captureSession?.addInput(captureInput! as! AVCaptureInput)
        }
        
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        if captureSession!.canAddOutput(captureMetadataOutput)
        {
            captureSession?.addOutput(captureMetadataOutput)
        }
        
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code]
        
        
        videoPreviewLayer = CaptureVideoLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.bounds
        videoPreviewLayer?.backgroundColor = UIColor.whiteColor().CGColor
        view.layer.addSublayer(videoPreviewLayer!)
        
        
        
        qrCodeFrameView = UIView(frame: CGRectMake(kLineMinX, kLineMinY, kReaderWidth, kReaderWidth))
        qrCodeFrameView?.layer.borderColor = UIColor.whiteColor().CGColor
        qrCodeFrameView?.layer.borderWidth = 2.0
        qrCodeFrameView?.addSubview(scanLabel!)
        view.addSubview(qrCodeFrameView!)
        
        captureMetadataOutput.rectOfInterest = CGRectMake(kLineMinY / kDeviceHeigth, kLineMinX / kDeviceWidth, kReaderWidth/kDeviceHeigth, kReaderWidth/kDeviceWidth)
        
        
        loadUI()
        animationView(scanLabel!)
        configureSquare()
    }
    
    
    func createThirdScaner()
    {
        
        scanImageView.hidden = false
        
        view.addSubview(scanImageView)
        var zbarReader = ZBarReaderController()
        zbarReader.readerDelegate = self

        if ZBarReaderController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            zbarReader.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
        }
        
        zbarReader.scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        self.presentViewController(zbarReader, animated: true, completion: nil)
    }

    lazy var scanImageView: UIImageView =
    {
        var scanImageView = UIImageView(frame: CGRectMake(kLineMinX, kLineMinY, kReaderWidth, kReaderHeight))
        return scanImageView
        
        }()
    
    func loadUI()
    {
        
        var topView = UIView(frame: CGRectMake(0, 0, kDeviceWidth, kLineMinY))
        topView.backgroundColor = UIColor.blackColor()
        topView.alpha = kAlpha
        view.addSubview(topView)
        
        var leftView = UIView(frame: CGRectMake(0, CGRectGetMaxY(topView.frame), (kDeviceWidth - kReaderWidth)/2, kReaderHeight))
        leftView.backgroundColor = UIColor.blackColor()
        leftView.alpha = kAlpha
        view.addSubview(leftView)
        
        var rightView = UIView(frame: CGRectMake(kDeviceWidth - (kDeviceWidth - kReaderWidth)/2, CGRectGetMaxY(topView.frame), (kDeviceWidth - kReaderWidth)/2, kReaderHeight))
        rightView.backgroundColor = UIColor.blackColor()
        rightView.alpha = kAlpha
        view.addSubview(rightView)
        
        
        var bottomView = UIView(frame: CGRectMake(0, CGRectGetMaxY(leftView.frame), kDeviceWidth, kDeviceHeigth - CGRectGetMaxY(leftView.frame)))
        bottomView.backgroundColor = UIColor.blackColor()
        bottomView.alpha = kAlpha
        view.addSubview(bottomView)
        
        var tips = UILabel(frame: CGRectMake(0, bottomView.frame.origin.y + 30, kDeviceWidth, 40))
        tips.text = "请将二维码/条形码放入扫描框内,即可自行扫描"
        tips.textColor = UIColor.whiteColor()
        tips.font = UIFont.boldSystemFontOfSize(12)
        tips.textAlignment = .Center
        view.addSubview(tips)
        
        messageLabel = UILabel(frame: CGRectMake(0, CGRectGetMaxY(tips.frame) + 10,kDeviceWidth, 40))
        messageLabel?.font = UIFont.boldSystemFontOfSize(12)
        messageLabel?.text = "我的二维码"
        messageLabel?.textAlignment = NSTextAlignment.Center
        messageLabel?.textColor = UIColor.greenColor()
        messageLabel?.userInteractionEnabled = true
        messageLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showDetail1"))
        view.addSubview(messageLabel!)
        
        let startScanButton = UIButton(frame: CGRectMake(0, 0, 120, 30))
        startScanButton.tag = 1000
        startScanButton.center = CGPointMake(self.view.bounds.width*0.5, CGRectGetMaxY(messageLabel!.frame)+20)
        startScanButton.setTitle("开始扫描", forState: .Normal)
        startScanButton.setTitle("正在扫描中...", forState: .Selected)
        startScanButton.titleLabel?.font = UIFont.systemFontOfSize(15)
        startScanButton.addTarget(self, action: "startRuning", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(startScanButton)
        
        scanLabel?.frame = CGRectMake(0, 0, kReaderWidth, 1)
        scanLabel?.backgroundColor = UIColor.greenColor()
        scanLabel?.layer.shadowColor = UIColor.greenColor().CGColor
        scanLabel?.layer.shadowOpacity = 1.0
        scanLabel?.layer.shadowRadius = 5.0
        scanLabel?.layer.shadowOffset = CGSizeMake(0, -5)
        scanLabel?.hidden = true
    }
    
    
    func showDetail()
    {
        let scanDetail = ScanDetailTableViewController()

        self.navigationController?.pushViewController(scanDetail, animated: true)
    }
    func showDetail1()
    {
        let scanDetail = ScanDetailCollectionViewController(collectionViewLayout:ScanViewLayout())

        self.navigationController?.pushViewController(scanDetail, animated: true)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0
        {
     
            messageLabel?.text = "NO QR code is detected"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode
        {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
       
            if metadataObj.stringValue != nil
            {
                insertItem(metadataObj.stringValue)
            
            }
          
        }else if metadataObj.type == AVMetadataObjectTypeEAN13Code
        {
            if metadataObj.stringValue != nil
            {
                insertItem(metadataObj.stringValue)
    
            }
            
        }
        
    }
        
    func insertItem(aString:String?)
    {
        if aString == nil {return}
        
        messageLabel?.text = aString
        stopRuning()
        var scanItem: ScanItem? =  ScanItem.insertShopIncomeItem(nil, inManagedObjectContext: stack.managedContext)
        scanItem?.scanDate = dateFormatter?.stringFromDate(NSDate())
        scanItem?.scanDetail = aString
        stack.managedContext.save(nil)
        
        addDocument()

        
    }
    
    func addDocument()->NSURL?
    {
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var newFileURL = NSFileManager.defaultManager().URLForUbiquityContainerIdentifier(nil)
            newFileURL = newFileURL?.URLByAppendingPathComponent("documents", isDirectory: true)
            newFileURL = newFileURL?.URLByAppendingPathComponent(self.newUntitledDocumentName(), isDirectory: false)
            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
                return newFileURL

//            })
//        })
      
        
    }
    
    
    func newUntitledDocumentName()->String
    {
        var txtCount: Int = 1
        var newTxtName: String?
        var done = false
        
        let documentArr = NSArray(array: documents ?? [])
        
        while !done
        {
            newTxtName = String(format: "scan %d.%@", txtCount, filenameExtension)
            var nameExists = false
            
            for fileURL in documentArr as! [NSURL]
            {
                if fileURL.lastPathComponent == newTxtName
                {
                    txtCount++
                    nameExists = true
                    break
                }
            }
            
            if !nameExists
            {
                done = true
            }
        }
        return newTxtName!
        
    }
    
    
    lazy var dateFormatter: NSDateFormatter? = {
      
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
       return  dateFormatter
        
    }()
    
  
    func stopRuning()
    {
        captureSession!.stopRunning()
        isStopScan = true
        let button = view.viewWithTag(1000) as! UIButton
        button.userInteractionEnabled = true
        button.selected = false
        scanLabel?.hidden = true
        
    }
    func startRuning()
    {
        let button = view.viewWithTag(1000) as! UIButton
        button.selected = true
        button.userInteractionEnabled = false
        captureSession?.startRunning()
        scanLabel?.hidden = false
        messageLabel?.text = "我的二维码"
        scanImageView.hidden = true
        scanImageView.image = nil
        
    }
    
    func animationView(lable: UILabel)
    {
        
        
        let animateSpeed = 5 / kReaderHeight
        var duration =  NSTimeInterval(animateSpeed * kReaderHeight)
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            lable.frame.origin.y = CGRectGetHeight(lable.superview!.frame) - 1
            
            }, completion: { _ in
                
                lable.frame.origin.y = 0

                self.animationView(lable)
 
        
        })
        
        
    }
    
    func configureSquare()
    {
        var path = UIBezierPath()
        
        for index in 0..<square.count
        {
            var w: CGFloat = 20
            var h: CGFloat = 2
            var cnt = 0
            var point: CGPoint = square[index]
            if index % 3 == 0
            {
                path.moveToPoint(point)
            }
            else if index % 3 == 1
            {
                path.addLineToPoint(point)
            }else
            {
                continue
            }
            
            
            switch (index)
            {
            case 0:
                
                var label = UILabel(frame: CGRectMake(0, 0, w, h))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 1:
                
                var label = UILabel(frame: CGRectMake(0, 0, h, w))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 3:
                
                var label = UILabel(frame: CGRectMake(0, 0, h, w))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 4:
                
                var label = UILabel(frame: CGRectMake(0, 0, w, h))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 6:
                
                var label = UILabel(frame: CGRectMake(0, 0, w, h))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 7:
                
                var label = UILabel(frame: CGRectMake(0, 0, h, w))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 9:
                
                var label = UILabel(frame: CGRectMake(0, 0, h, w))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            case 10:
                
                var label = UILabel(frame: CGRectMake(0, 0, w, h))
                label.frame.origin = point
                label.backgroundColor = UIColor.greenColor()
                view.addSubview(label)
                
            default: break
                
            }
        
        }
        
    }
    
}


extension ViewController: ZBarReaderDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        stopRuning()
        
        let results: AnyObject? = info[ZBarReaderControllerResults]

        var symbol: ZBarSymbol?
        for symbol1 in results as! [ZBarSymbol]
        {
            symbol = symbol1
            break
        }
    
        insertItem(symbol?.data)
        scanImageView.image = (info as NSDictionary)[UIImagePickerControllerOriginalImage] as? UIImage
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func readerControllerDidFailToRead(reader: ZBarReaderController!, withRetry retry: Bool) {
       
        reader.dismissViewControllerAnimated(true, completion: nil)
    }
    
}









