//
//  PFLSwiftAlertView.swift
//  JiuDingPay
//
//  Created by pfl on 15/9/29.
//  Copyright © 2015年 QianHai Electronic Pay. All rights reserved.
//

import UIKit
import AudioToolbox



let leadingX: CGFloat = 10
let trailingX: CGFloat = 10
let topYY: CGFloat = 40
let itemH: CGFloat = 30
let fontSize: CGFloat = 14
let btnH: CGFloat = 44
let alertViewWidth: CGFloat = 250
let deltaY: CGFloat = 5
let aCenter: CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)

enum AlertViewType {
    case PlainType,TextFieldType
}




@objc protocol PFLSwiftAlertViewDelegate {
    @objc optional
    func didClick(_ alertView: PFLSwiftAlertView, cancelButton:UIButton)
    @objc optional
    func didClick(_ alertView: PFLSwiftAlertView, confirmButton:UIButton)
}

typealias cancelClosure = ()->()
typealias confirmClosure = ()->()
typealias textFieldDidEndEditingClosure = (_ sting: String)->()
typealias didSelectedIndexPathClosures = (String, NSInteger)->()





class PFLSwiftAlertView: UIView, Animationable {

    var touchDismiss = false
    var didClickedCancelBtnClosure: cancelClosure?
    var didClickedConfirmBtnClosure: confirmClosure?
    var textFieldDidEndEditClosure: textFieldDidEndEditingClosure?
    var didSelectedIndexPathClosure: didSelectedIndexPathClosures?
    var passwordLength: Int = 6
    var message: String? {
        didSet {
            self.messageLabel?.text = message
        }
    }
    
    var contentFont: CGFloat = 14
    
    fileprivate var delegate: PFLSwiftAlertViewDelegate?
    fileprivate var cancelButtonTitle: String?
    var confirmButtonTitle: String? {
        didSet {
            if let btn = confirmBtn {
                btn.setTitle(confirmButtonTitle, for: UIControl.State.normal)
            }
        }
    }
    fileprivate var tableView: UITableView?
    
    var title: String? {
        didSet {
            self.titleLabel?.text = title
        }
    }
    
    /**
     自定义alertView
     
     - parameter title:             标题
     - parameter message:           信息
     - parameter delegate:          代理
     - parameter cancelButtonTitle: 取消按钮
     - parameter otherButtonTitle:  确定按钮
     
     - returns: alertView
     */
    required init(title: String? = "提示", message: String?, delegate: AnyObject?, cancelButtonTitle: String?, otherButtonTitle: String?) {
        let rect: CGRect = CGRect(x: 0, y: 0, width: alertViewWidth, height: 100)
        super.init(frame:rect)
        self.title = title
        self.delegate = delegate as? PFLSwiftAlertViewDelegate
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmButtonTitle = otherButtonTitle
        self.frame = rect
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10.0
        self.layer.masksToBounds = true
        NotificationCenter.default.addObserver(self, selector: #selector(PFLSwiftAlertView.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PFLSwiftAlertView.keyboardDidHide(_:)), name:UIResponder.keyboardDidHideNotification, object: nil)
        
        if let _ = title {
            self.contentView.addSubview(self.titleLabel!)
        }
        
        if let _ = message {
            self.contentView.addSubview(self.messageLabel!)
        }
        
        if let _ = cancelButtonTitle {
            self.contentView.addSubview(self.cancelBtn!)
        }
        
        if let _ = confirmButtonTitle {
            self.contentView.addSubview(self.confirmBtn!)
        }
        
        self.contentView.addSubview(self.topLine)
        
        if let _ = cancelButtonTitle, let _ = confirmButtonTitle {
            self.contentView.addSubview(self.midLine!)
        }
        
        self.adjustCenter()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    convenience init(withTableView tableView:UITableView) {
        self.init(title: "交易类别", message: nil, delegate: nil, cancelButtonTitle: nil, otherButtonTitle: "确定")
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.contentView.addSubview(tableView)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets.zero;
        self.frame = CGRect(x: 0, y: 0, width: alertViewWidth, height: 400)
        tableView.frame = CGRect(x: 0, y: 40, width: self.bounds.width, height: self.bounds.height)
        adjustCenter()
    }
    
    var inputTextFieldPlaceholder = "请输入支付密码" {
        didSet {
            self.inputTextField.placeholder = inputTextFieldPlaceholder
        }
    }

    var dataSource: [String]? {
        didSet {
            if let tableView = self.tableView {
                if let dataSource = self.dataSource {
                    print(dataSource.count)
                    self.topY = CGFloat(dataSource.count) * itemH > 400 ? 400:CGFloat(dataSource.count) * itemH + btnH + itemH
                    tableView.frame.size.height = self.bounds.height - 40
                    adjustCenter()
                }
            }
        }
    }
    
    //MARK: itemsArr 与 hasTextField 不能同时设置
    var itemsArr: NSArray? {
        didSet {
            
            guard  self.alertViewType != .TextFieldType else {return};
            
            if let arr = itemsArr {
                if arr.count > 0 {
                    var y: CGFloat = 0;
                    if let lab = self.messageLabel {
                        y = lab.frame.maxY + topY / 4
                    }
                    else {
                        y = topY
                    }
                    for i in 0..<arr.count {
                        let label = UILabel(frame: CGRect(x: leadingX, y: y + CGFloat(i) * itemH, width: self.bounds.width - 2*leadingX, height: itemH))
                        label.text = arr[i] as? String
                        label.textAlignment = .left
                        label.textColor = UIColor.brown
                        label.font = UIFont.systemFont(ofSize: contentFont)
                        label.numberOfLines = 0
                        label.lineBreakMode = NSLineBreakMode.byWordWrapping
                        label.frame.size.height = self.getLabelHeight(label)
                        self.contentView.addSubview(label)
                        self.topY += itemH
                    }
                    
                    self.adjustCenter()
                }
            }
        }
    }
    
    //MARK:  itemsArr 与 hasTextField 不能同时设置
    fileprivate var hasTextField: String? {
        didSet {
            if let _ = hasTextField {
                self.contentView.addSubview(self.inputTextField)
                IQKeyboardManager.shared().isEnabled = false
            }
        }
    }
    
    var alertViewType: AlertViewType = .PlainType {
        didSet {
            switch (alertViewType) {
            case .PlainType:
                break
            case .TextFieldType:
                guard let itemsArr = itemsArr , itemsArr.count > 0 else {
                    self.contentView.addSubview(self.inputTextField)
                    IQKeyboardManager.shared().isEnabled = false
                    break
                }
                
            }
        }
    }

    var textFieldHeight: CGFloat = itemH {
        didSet {
            guard  alertViewType == .TextFieldType else{return}
            inputTextField.frame.size.height = textFieldHeight;
        }
    }
    
    
    fileprivate var topY: CGFloat = 0 {
        didSet {
            topY = topY>40 ? topY : 40
            self.frame.size.height = topY
            self.contentView.frame.size.height = topY
            self.center = aCenter
            print(self.contentView.frame)
            print(self.frame)
        }
    }
    
    @objc fileprivate func keyboardDidHide(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        }) 
        
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        
        let kbHeight:CGFloat = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size.height
        let kbRect: CGRect = CGRect(x: 0, y: UIScreen.main.bounds.height - kbHeight, width: UIScreen.main.bounds.width, height: kbHeight)
        let point: CGPoint = CGPoint(x: self.bounds.minX, y: self.bounds.height/2 + UIScreen.main.bounds.height/2)

        if (kbRect.contains(point)) {
            let deltaY: CGFloat =  point.y - kbRect.origin.y;
            self.frame.origin.y -= deltaY
        }
    }

    lazy fileprivate var contentView: UIView = {
        var contentView = UIView(frame: self.bounds)
        self.addSubview(contentView)
        return contentView
    }()
    
    lazy fileprivate var titleLabel: UILabel? = {
        
        if let title = self.title {
            var titleLabel: UILabel = UILabel(frame: CGRect(x: 20, y: leadingX, width: self.bounds.width-40, height: itemH))
            titleLabel.text = self.title
            titleLabel.font = UIFont.systemFont(ofSize: fontSize)
            titleLabel.textAlignment = .center
            self.contentView.addSubview(titleLabel)
            self.topY = titleLabel.frame.maxY
            return titleLabel
        }
        else {
            return nil
        }
    }()
    
    
    var isCenter: Bool = true {
        didSet {
            titleLabel?.textAlignment = isCenter ? .center : .left
        }
    }
    
    lazy fileprivate var messageLabel: UILabel? = {
        if let message = self.message {
            var messageLabel: UILabel = UILabel(frame: CGRect(x: 0, y: self.titleLabel!.frame.maxY, width: self.bounds.width, height: itemH))
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: fontSize)
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            messageLabel.textAlignment = .center
            messageLabel.frame.size.height = self.getLabelHeight(messageLabel);
            self.contentView.addSubview(messageLabel)
            self.topY = messageLabel.frame.maxY
            return messageLabel
 
        }
        else {
            return nil
        }
    }()

    lazy fileprivate var cancelBtn: UIButton? = {
        if let cancelTitle = self.cancelButtonTitle {
            var btn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width * 0.5, height: btnH))
            btn.center = CGPoint(x: self.bounds.midX, y: self.topY + btnH * 0.5)
            btn.addTarget(self, action: #selector(PFLSwiftAlertView.btnPressed(_:)), for: .touchUpInside)
            btn.tag = 1
            btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize + 1)
            btn.setTitle(cancelTitle, for: UIControl.State.normal)
            btn.setTitleColor(UIColor.red, for: UIControl.State.normal)
            return btn
        }
        else {
            return nil
        }
    }()
    
    var cancelBtnColor: UIColor = UIColor.red {
        didSet {
            guard let cancelBtn = cancelBtn else {return}
            cancelBtn.setTitleColor(cancelBtnColor, for: UIControl.State.normal)
        }
    }
    
    
    var confirmBtnColor: UIColor = UIColor.red {
        didSet {
            guard let confirmBtn = confirmBtn else {return}
            confirmBtn.setTitleColor(confirmBtnColor, for: UIControl.State.normal)
        }
    }


    
    lazy fileprivate var confirmBtn: UIButton? = {
        if let confirmTitle = self.confirmButtonTitle {
            var btn: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.bounds.width * 0.5, height: btnH))
            btn.center = CGPoint(x: self.bounds.midX, y: self.topY + btnH * 0.5)
            btn.addTarget(self, action: #selector(PFLSwiftAlertView.btnPressed(_:)), for: .touchUpInside)
            btn.tag = 2
            btn.titleLabel?.font = UIFont.systemFont(ofSize: fontSize + 1)
            btn.setTitle(confirmTitle, for: UIControl.State.normal)
            btn.setTitleColor(UIColor.red, for: UIControl.State.normal)
            return btn
        }
        else {
            return nil
        }
        }()
    
    lazy fileprivate var dynamicAnimator: UIDynamicAnimator = {
        var dynamicAnimator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.bgWindow)
        return dynamicAnimator
    }()
    
    lazy fileprivate var bgWindow: UIWindow = {
        var bgWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
        bgWindow.makeKeyAndVisible()
        return bgWindow
        }()

    lazy fileprivate var bgCoverView: UIView = {
        var bgCoverView: UIView = UIView(frame: UIScreen.main.bounds)
        bgCoverView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        if self.touchDismiss {
            bgCoverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAlertView)))
        }
        return bgCoverView
        }()

    lazy fileprivate var topLine: UIView = {
        
        var y: CGFloat =  (self.cancelBtn != nil) ? self.cancelBtn!.frame.minY : self.confirmBtn!.frame.minY
        var topLine: UIView = UIView(frame: CGRect(x: 0, y: y - 0.5, width: self.bounds.width, height: 1))
        topLine.backgroundColor = UIColor.lightGray
        return topLine
    }()
    
    lazy fileprivate var midLine: UIView? = {
        if let _ = self.cancelButtonTitle,  let _ = self.confirmButtonTitle {
            var midLine: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: btnH))
            midLine.center = CGPoint(x: self.bounds.midX, y: self.confirmBtn!.frame.minY)
            midLine.backgroundColor = UIColor.lightGray
            return midLine
        }
        else {
            return nil
        }
    }()
    
    lazy var inputTextField: UITextField = {
        
        var y: CGFloat = topYY/4
        if let msgL = self.messageLabel {
            y = msgL.frame.maxY + topYY/4
        }
        else if let titleL = self.titleLabel {
            y = titleL.frame.maxY + topYY/4
        }
        var inputTextField: UITextField = UITextField(frame: CGRect(x: leadingX, y: y, width: self.bounds.width-2*leadingX, height: itemH))
        self.topY = inputTextField.frame.maxY + topYY/4
        inputTextField.placeholder = self.inputTextFieldPlaceholder
        inputTextField.textAlignment = .center
        inputTextField.font = UIFont.systemFont(ofSize: fontSize-1)
        inputTextField.delegate = self
        inputTextField.layer.cornerRadius = 3
        inputTextField.layer.borderWidth = 1
        inputTextField.layer.borderColor = UIColor.gray.cgColor
        inputTextField.layer.masksToBounds = true
        self.adjustCenter()
        return inputTextField
    }()

    
    fileprivate func getLabelHeight(_ label: UILabel) -> CGFloat {
        
        var height: CGFloat = 0
        guard let text = label.text else {return height}
        if (UIDevice.current.systemVersion as NSString).floatValue >= 7.0 {
            height = text.boundingRect(with: CGSize(width: label.frame.width, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:label.font], context: nil).size.height
        }
        else {
            height = text.size(withAttributes: [NSAttributedString.Key.font:label.font]).height
        }
        return height
    }
    
    
    @objc fileprivate func btnPressed(_ btn: UIButton) {
        
        self.inputTextField.endEditing(true)
        
        switch (btn.tag) {
        case 1:
            if let cancelB = self.didClickedCancelBtnClosure {
                cancelB()
            }
            if let delegate = self.delegate {
                if (delegate as AnyObject).responds(to: #selector(PFLSwiftAlertViewDelegate.didClick(_:cancelButton:))) {
                    delegate.didClick!(self, cancelButton: btn)
                }
                
            }
            
        case 2:
            
            if hasTextField != nil || alertViewType == .TextFieldType {
                if let txt = inputTextField.text , txt.utf8.count == 0 || txt.characters.count < passwordLength {
                    animationForNoneString()
                    return
                }
            }
            
            
            
            if let confirmB = self.didClickedConfirmBtnClosure {
                confirmB()
            }
            if let delegate = self.delegate {
                if (delegate as AnyObject).responds(to: #selector(PFLSwiftAlertViewDelegate.didClick(_:confirmButton:))) {
                    delegate.didClick!(self, confirmButton: btn)
                }
            }

        default: break
        }
        self.dismissAlertView()
    }
    
    
    func animationForNoneString() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        let animationKeyPath = CAKeyframeAnimation(keyPath: "position.x")
        let centerX = self.bounds.midX * 0
        animationKeyPath.values = [centerX-6,centerX-4,centerX-2,centerX,centerX+2,centerX+4,centerX+6]
        animationKeyPath.keyTimes = [NSNumber(value: 0.1 as Float),NSNumber(value: 0.2 as Float),NSNumber(value: 0.4 as Float),NSNumber(value: 0.6 as Float),NSNumber(value: 0.7 as Float),NSNumber(value: 0.8 as Float),NSNumber(value: 0.9 as Float),NSNumber(value: 1.0 as Float)]
        animationKeyPath.duration = 0.3
        animationKeyPath.isAdditive = true
        self.inputTextField.layer .add(animationKeyPath, forKey: "shake")
    }
    
    fileprivate func adjustCenter() {
        
        if let _ = self.confirmButtonTitle {
            self.confirmBtn?.frame.size.width = self.bounds.width
            self.confirmBtn?.center.y = self.topY + btnH * 0.5 + deltaY
            self.confirmBtn?.center.x = self.bounds.width * 0.5
        }
        if let _ = self.cancelButtonTitle {
            self.cancelBtn?.frame.size.width = self.bounds.width
            self.cancelBtn?.center.y = self.topY + btnH * 0.5 + deltaY
            self.cancelBtn?.center.x = self.bounds.width * 0.5
        }
        if let _ = self.cancelButtonTitle, let _ = self.confirmButtonTitle {
            self.cancelBtn?.frame.size.width = self.bounds.width * 0.5
            self.confirmBtn?.frame.size.width = self.bounds.width * 0.5
            self.cancelBtn?.center.x = self.bounds.width * 0.25
            self.confirmBtn?.center.x = self.bounds.width * 0.75
            self.midLine!.center.y = self.cancelBtn!.center.y
            
        }
        
        if (self.cancelButtonTitle != nil) {
            self.topLine.center.y = self.cancelBtn!.frame.minY
        }
        else {
            self.topLine.center.y = self.confirmBtn!.frame.minY
        }
        self.topY += btnH + deltaY
        
        
    }
    
    
        
    func show() {
        self.bgWindow.addSubview(self.bgCoverView)
        self.bgWindow.addSubview(self)
        self.dynamicAnimator.addBehavior(self.addDropBehavior())
        self.performAnimation()
        self.dynamicAnimator.removeAllBehaviors()
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAlertView), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc fileprivate func dismissAlertView() {
        self.dismissAnimation()
        self.dynamicAnimator.addBehavior(addBehavior())
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 0.31)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            self.bgCoverView.removeFromSuperview()
            for vi in self.subviews {
                vi.removeFromSuperview()
            }
            self.removeFromSuperview()
            self.bgWindow.isHidden = true
            UIApplication.shared.windows.first?.makeKey()
            self.dynamicAnimator.removeAllBehaviors()
        }
    }
    
    deinit {
        IQKeyboardManager.shared().isEnabled = true
        NotificationCenter.default.removeObserver(self)
        print("deinit=============")
    }
}

extension PFLSwiftAlertView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let isEndBlock = self.textFieldDidEndEditClosure, let txt = textField.text {
            isEndBlock(txt)
        }
    }
}


extension PFLSwiftAlertView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource = self.dataSource {
            return dataSource.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = self.dataSource![indexPath.row] as String
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont.systemFont(ofSize: contentFont)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if let closure = self.didSelectedIndexPathClosure, let dataSource = dataSource {
            closure(dataSource[indexPath.row], indexPath.row)
        }
        self.dismissAlertView()

    }
    
}












