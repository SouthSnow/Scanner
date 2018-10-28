//
//  ScanViewController.swift
//  Scanner
//
//  Created by pfl on 15/5/13.
//  Copyright (c) 2015年 pfl. All rights reserved.
//

import UIKit
import AVFoundation
import StoreKit

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
let kDeviceWidth: CGFloat = UIScreen.main.bounds.width
let kDeviceHeigth: CGFloat = UIScreen.main.bounds.height
let kLineMinX: CGFloat = kDeviceWidth/2 - kReaderWidth/2
let kLineMinY: CGFloat = kDeviceHeigth/2 - kReaderHeight/2 - 50

let filenameExtension = "txt"

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: CaptureVideoLayer?
    var qrCodeFrameView: UIView?
    var messageLabel: UILabel?
    var scanLabel: UILabel? = UILabel()
    var isStopScan: Bool = false
    var isFromAlbum = false
    var isAnimation: Bool? = false
    var managedObjectContext: NSManagedObjectContext?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var metadataQuery: NSMetadataQuery?
    var documents: NSMutableArray?
    var stack: PersistentStack!
    
    var scanView: SWScanView!
    
    var scanner: ScanCodeManager! = nil
    
    var coverView: UIView? {
        didSet {
            coverView?.backgroundColor = UIColor.black
            coverView?.layer.opacity = 0.6
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("============deinit================")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stack = (UIApplication.shared.delegate as! AppDelegate).stack
        self.view.backgroundColor = UIColor.black
        self.title = "扫描/查询"
        self.navigationController?.navigationBar.barTintColor = UIColor.green//(red: 0.863, green: 0.243, blue: 0.051, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "扫描历史", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ScanViewController.showDetail))
        let albumItem = UIBarButtonItem(title: "相册", style: UIBarButtonItem.Style.plain, target: self, action: #selector(openAlbum))
        let backItem = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(clickBackAction(sender:)))
        self.navigationItem.leftBarButtonItems = [backItem, albumItem]
        
        NotificationCenter.default.addObserver(self, selector: #selector(startRuning), name: UIApplication.didBecomeActiveNotification, object: nil)

        createSystemSCaner()
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFromAlbum {
            isFromAlbum = false
            return
        }
        if !isStopScan {
            SWDispatchAfterDoSomething(0.5) {
                self.startRuning()
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRuning()
        isStopScan = false
    }
    
    @objc func clickBackAction(sender:Any) {
        stopRuning()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setupAndStartQuery() {
        if let metadataQuery = metadataQuery {
        }
        else {
            metadataQuery = NSMetadataQuery()
            metadataQuery?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
            let filePattern = String(format: "*.%@", filenameExtension)
            metadataQuery?.predicate = NSPredicate(format: "%K LIKE %@", filePattern)
            metadataQuery?.start()
            
            // MARK: register notification
            NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.processFile(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(ScanViewController.processFile(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
        }
    }
    
    @objc func processFile(_ notifition: Notification) {
        metadataQuery?.disableUpdates()
        documents = NSMutableArray()
        let results = metadataQuery?.results
        let fileItemArr: NSMutableArray = NSMutableArray()
        for metadataItem in results as! [NSMetadataItem] {
            let fileURL = metadataItem.value(forAttribute: NSMetadataItemURLKey) as! URL
            do {
                let nill:(AutoreleasingUnsafeMutablePointer<AnyObject?>)? = nil
                try (fileURL as NSURL).getResourceValue(nill!, forKey: URLResourceKey.isHiddenKey)
            } catch _ {
            }
            fileItemArr.add(fileURL)
        }
        documents?.removeAllObjects()
        documents?.addObjects(from: fileItemArr as [AnyObject])
        metadataQuery?.enableUpdates()
    }
    
    
    func createSystemSCaner() {
        self.scanView = SWScanView(frame: self.view.bounds)
        self.scanView.previewRectOfInterest = CGRect(x: kLineMinX, y: kLineMinY, width: kReaderHeight, height: kReaderHeight)
        self.scanView.torchPressedAction = { btn in
            guard let btn = btn else {return}
        }
        self.view.addSubview(self.scanView)
        self.scanner = ScanCodeManager(presentedViewController: self, previewLayerView: self.scanView, rectOfInterest: CGRect(x: kLineMinX, y: kLineMinY, width: kReaderHeight, height: kReaderHeight), handler: {[unowned self] (str) in
            if let str = str as? String {
                self.insertItem(str)
            }
        }, torchHandler: {[unowned self] (open) -> Bool in
            self.scanView.torchView.isHidden = !open
            return self.scanView.torchBtn.isSelected
        })
        self.scanner.addInterest(withScanView: self.scanView)
        
        loadUI()
        configureSquare()
        self.scanView.bringSubviewToFront(self.scanView.torchView)
    }
    
    @objc private func openAlbum() {
        self.isFromAlbum = true
        self.scanner.chooseQRCode {[unowned self] (image) in
            self.isFromAlbum = false
            guard let image = image else {return}
            self.scanImageView.isHidden = false
            self.scanImageView.image = image
        }
    }
    
    lazy var scanImageView: UIImageView = {
        var scanImageView = UIImageView(frame: CGRect(x: kLineMinX, y: kLineMinY, width: kReaderWidth, height: kReaderHeight))
        self.view.addSubview(scanImageView)
        return scanImageView
    }()
    
    func loadUI() {
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kLineMinY))
        topView.backgroundColor = UIColor.black
        topView.alpha = kAlpha
        view.addSubview(topView)
        
        let leftView = UIView(frame: CGRect(x: 0, y: topView.frame.maxY, width: (kDeviceWidth - kReaderWidth)/2, height: kReaderHeight))
        leftView.backgroundColor = UIColor.black
        leftView.alpha = kAlpha
        view.addSubview(leftView)
        
        let rightView = UIView(frame: CGRect(x: kDeviceWidth - (kDeviceWidth - kReaderWidth)/2, y: topView.frame.maxY, width: (kDeviceWidth - kReaderWidth)/2, height: kReaderHeight))
        rightView.backgroundColor = UIColor.black
        rightView.alpha = kAlpha
        view.addSubview(rightView)
        
        
        let bottomView = UIView(frame: CGRect(x: 0, y: leftView.frame.maxY, width: kDeviceWidth, height: kDeviceHeigth - leftView.frame.maxY))
        bottomView.backgroundColor = UIColor.black
        bottomView.alpha = kAlpha
        view.addSubview(bottomView)
        
        let tips = UILabel(frame: CGRect(x: 0, y: bottomView.frame.origin.y + 30, width: kDeviceWidth, height: 40))
        tips.text = "请将二维码/条形码放入扫描框内,即可自行扫描"
        tips.textColor = UIColor.white
        tips.font = UIFont.boldSystemFont(ofSize: 12)
        tips.textAlignment = .center
        view.addSubview(tips)
        
        messageLabel = UILabel(frame: CGRect(x: 5, y: tips.frame.maxY + 10,width: kDeviceWidth-10, height: 40))
        messageLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        messageLabel?.text = "我的快递"
        messageLabel?.textAlignment = NSTextAlignment.center
        messageLabel?.textColor = UIColor.green
        messageLabel?.isUserInteractionEnabled = true
        messageLabel?.numberOfLines = 2
        messageLabel?.lineBreakMode = .byWordWrapping
        messageLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanViewController.showDetail1)))
        view.addSubview(messageLabel!)
        
        let startScanButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
        startScanButton.tag = 1000
        startScanButton.center = CGPoint(x: self.view.bounds.width*0.5, y: messageLabel!.frame.maxY+20)
        startScanButton.setTitle("开始扫描", for: UIControl.State())
        startScanButton.setTitle("正在扫描中...", for: .selected)
        startScanButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        startScanButton.addTarget(self, action: #selector(ScanViewController.startRuning), for: UIControl.Event.touchUpInside)
        view.addSubview(startScanButton)
        
        scanLabel?.frame = CGRect(x: 0, y: 0, width: kReaderWidth, height: 1)
        scanLabel?.backgroundColor = UIColor.green
        scanLabel?.layer.shadowColor = UIColor.green.cgColor
        scanLabel?.layer.shadowOpacity = 1.0
        scanLabel?.layer.shadowRadius = 5.0
        scanLabel?.layer.shadowOffset = CGSize(width: 0, height: -5)
        scanLabel?.isHidden = true
    }
    
    
    @objc func showDetail() {
        let scanDetail = ScanDetailTableViewController()
        self.navigationController?.pushViewController(scanDetail, animated: true)
    }
    @objc func showDetail1() {
        guard let detail = self.messageLabel?.text, detail.length > 0, detail.pureNumberString else {
            showDetail()
            return
        }
        let scanDetail = ExpressViewController(expressno: self.messageLabel?.text)
        self.navigationController?.pushViewController(scanDetail, animated: true)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            messageLabel?.text = "NO QR code is detected"
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            _ = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            if metadataObj.stringValue != nil {
                insertItem(metadataObj.stringValue)
            }
        }
        else if metadataObj.type == AVMetadataObject.ObjectType.ean13 {
            if metadataObj.stringValue != nil {
                insertItem(metadataObj.stringValue)
            }
        }
    }
        
    func insertItem(_ aString:String?) {
        if aString == nil {return}
        messageLabel?.text = aString
        stopRuning()
        guard let stack = self.stack else {
            return
        }
        let scanItem: ScanItem? =  ScanItem.insertShopIncomeItem(nil, in: stack.managedContext)
        scanItem?.scanDate = dateFormatter?.string(from: Date())
        scanItem?.scanDetail = aString
        do {
            try stack.managedContext.save()
        } catch _ {
        }
        _ = addDocument()
    }
    
    func addDocument()->URL? {
        var newFileURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)
        newFileURL = newFileURL?.appendingPathComponent("documents", isDirectory: true)
        newFileURL = newFileURL?.appendingPathComponent(self.newUntitledDocumentName(), isDirectory: false)
        return newFileURL
    }
    
    
    func newUntitledDocumentName()->String {
        var txtCount: Int = 1
        var newTxtName: String?
        var done = false
        let documentArr = NSArray(array: documents ?? [])
        while !done {
            newTxtName = String(format: "scan %d.%@", txtCount, filenameExtension)
            var nameExists = false
            for fileURL in documentArr as! [URL] {
                if fileURL.lastPathComponent == newTxtName {
                    txtCount += 1
                    nameExists = true
                    break
                }
            }
            
            if !nameExists {
                done = true
            }
        }
        return newTxtName!
    }
    
    lazy var dateFormatter: DateFormatter? = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       return  dateFormatter
    }()
    
  
    func stopRuning() {
        if let _ = scanner {
            scanner.stopRun()
        }
        self.scanView.stratAnimation()
        guard let button = view.viewWithTag(1000) as? UIButton else {return}
        button.isUserInteractionEnabled = true
        button.isSelected = false
        scanLabel?.isHidden = true
        
    }
    @objc func startRuning() {
        if UIApplication.topViewController() != self {return}
        guard let button = view.viewWithTag(1000) as? UIButton else {return}
        button.isSelected = true
        button.isUserInteractionEnabled = false
        if let _ = scanner {
            scanner.startRun()
        }
        self.scanView.stratAnimation()
        scanLabel?.isHidden = false
        messageLabel?.text = "我的快递"
        scanImageView.isHidden = true
        scanImageView.image = nil
    }
    
    func animationView(_ lable: UILabel) {
        let animateSpeed = 5 / kReaderHeight
        let duration =  TimeInterval(animateSpeed * kReaderHeight)
        
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: { () -> Void in
            
            lable.frame.origin.y = lable.superview!.frame.height - 1
            
            }, completion: { _ in
                
                lable.frame.origin.y = 0

                self.animationView(lable)
 
        
        })
        
        
    }
    
    func configureSquare() {
        let path = UIBezierPath()
        for index in 0..<square.count {
            let w: CGFloat = 20
            let h: CGFloat = 2
            var cnt = 0
            let point: CGPoint = square[index]
            if index % 3 == 0 {
                path.move(to: point)
            }
            else if index % 3 == 1 {
                path.addLine(to: point)
            }
            else {
                continue
            }
            
            
            switch (index) {
            case 0:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 1:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: h, height: w))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 3:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: h, height: w))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 4:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 6:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
            case 7:
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: h, height: w))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 9:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: h, height: w))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            case 10:
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: w, height: h))
                label.frame.origin = point
                label.backgroundColor = UIColor.green
                view.addSubview(label)
                
            default: break
                
            }
        
        }
        
    }
    
}





extension ScanViewController {
    fileprivate func queryExpressMerchantInfo(withOrder: String) {
        
    }
}








