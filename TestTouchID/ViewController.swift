//
//  ViewController.swift
//  TestTouchID
//
//  Created by Hung Chang Lo on 06/30/16.
//  Copyright © 2016 GO-Trust. All rights reserved.
//

import UIKit
import LocalAuthentication
import Security

class ViewController: UIViewController {
    @IBOutlet weak var txtStatus: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
        Description: Test Touch ID
     */
    @IBAction func btnTouchIDLocalAuth_onClick(_ sender: AnyObject) {
        txtStatus.text = nil
        let authContext = LAContext()
        var nsError: NSError?
        //.DeviceOwnerAuthenticationWithBiometrics
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &nsError) else {
            txtStatus.text = "Can not authenticate with biometrics"
            return
        }
        authContext.evaluatePolicy(.deviceOwnerAuthentication,
                                   localizedReason: "Test your finder print authentication",
                                   reply: localAuthReply )
        
    }
    
    func localAuthReply(_ succ: Bool, nserr: Error?) {
        let mainQ = DispatchQueue.main
        mainQ.async {
            if succ {
                self.txtStatus.text = "Local Auth Success"
            }
            else {
                let description = nserr?.localizedDescription
                NSLog("error description = \(description.debugDescription)")
                self.txtStatus.text = description
            }
        }
    }
    
    
    let TAG_KEYCHAIN_TEST_ITEM = "TAG_KEYCHAIN_TEST_ITEM"
    
    /**
        Descrption: Add item to keychain
     */
    @IBAction func btnAddItem_onClick(_ sender: AnyObject) {
        let password = "This is a secret password for Willey!"
        let pwdData: Data = password.data(using: String.Encoding.utf8)!
        
        var error: Unmanaged<CFError>?
        let sacObj: SecAccessControl? = SecAccessControlCreateWithFlags(
                    kCFAllocatorDefault,
                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                    SecAccessControlCreateFlags.userPresence,
                    &error)
        if sacObj == nil || error != nil {
            NSLog("ERROR: failed to create SecAccessControlRef")
            return
        }
        
        let params: [NSString: AnyObject] = [
            kSecClass               : kSecClassGenericPassword,
            kSecAttrAccount         : TAG_KEYCHAIN_TEST_ITEM as AnyObject,
            kSecValueData           : pwdData as AnyObject,
            kSecAttrAccessControl   : sacObj!
        ]
        
        let globalQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        globalQ.async {
            SecItemDelete(params as CFDictionary)
            let status: OSStatus = SecItemAdd(params as CFDictionary, nil)
            let errString = self.keychainErrorToString(status)
            
            let mainQ = DispatchQueue.main
            mainQ.async {
                self.txtStatus.text = errString
            }
        }
    }
    
    
    /**
        Description: Authentication with system Touch ID
     */
    @IBAction func btnTouchIDKeychainAuth_onClick(_ sender: AnyObject) {
        
        let params: [NSString: AnyObject] = [
            kSecClass               : kSecClassGenericPassword,
            kSecAttrAccount         : TAG_KEYCHAIN_TEST_ITEM as AnyObject,
            kSecReturnData          : true as AnyObject,
            kSecMatchLimit          : kSecMatchLimitOne,
            kSecUseOperationPrompt  : "Authenticate to use keychain password" as AnyObject
        ]
        
        var result: AnyObject?
        let status: OSStatus? = SecItemCopyMatching(params as CFDictionary, &result)
        print("keychainGetWrapSym.SecItemCopyMatching=\(self.keychainErrorToString(status!))")
        
        var resultStr: String = "\(self.keychainErrorToString(status!)), "
        //if found, return password
        if status == errSecSuccess {
            let data = result as! Data
            let string = String(data: data, encoding: String.Encoding.utf8)!
            resultStr = resultStr + string
        }
        
        let mainQ = DispatchQueue.main
        mainQ.async {
            self.txtStatus.text = resultStr
        }
    }
    
    
    
    @IBAction func btnTouchIDQuitWithTimeout(_ sender: UIButton) {
        authenticateWithTimeout(seconds: 10)
    }
    
    /**
        Description: Test Touch ID with timeout

        - parameters: Number seconds
     */
    func authenticateWithTimeout(seconds: Int) {
        let context = LAContext()
        
        let semophore = DispatchSemaphore(value: 0)
        let semophore_timeout = DispatchTime.now() + Double(seconds*1000*1000*1000) / Double(NSEC_PER_SEC)
        
        
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { (success, error) in
            NSLog("Error: \(error.debugDescription)")
            guard success else {
                DispatchQueue.main.async {
                    // show something here to block the user from continuing
                }
                semophore.signal()
                return
            }
            
            DispatchQueue.main.async {
                // do something here to continue loading your app, e.g. call a delegate method
            }
        }
        
        _ = semophore.wait(timeout: semophore_timeout)
        context.invalidate()
        let mainQ = DispatchQueue.main
        mainQ.async {
            self.txtStatus.text = "USER INFO: Touch ID timeout"
        }
    }
    
    /**
        Convert keychain error to string
     */
    func keychainErrorToString(_ status: OSStatus) -> String {
        var message = String(format: "error=%d", status)
        switch (status) {
        case errSecSuccess:
            message = "errSecSuccess"
        case errSecUnimplemented:
            message = "errSecUnimplemented"
        case errSecParam:
            message = "errSecParam"
        case errSecAllocate:
            message = "errSecAllocate"
        case errSecNotAvailable:
            message = "errSecNotAvailable"
        case errSecAuthFailed:
            message = "errSecAuthFailed"
        case errSecDuplicateItem:
            message = "errSecDuplicateItem"
        case errSecItemNotFound:
            message = "errSecItemNotFound"
        case errSecInteractionNotAllowed:
            message = "errSecInteractionNotAllowed"
        case errSecDecode:
            message = "errSecDecode"
        case errSecParam:
            message = "errSecParam"
        case errSecParam:
            message = "errSecParam"
        default:
            break
        }
        return message
    }
}

