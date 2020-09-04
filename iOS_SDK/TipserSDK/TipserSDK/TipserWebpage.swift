//
//  TipserWebpage.swift
//  TipserSDK
//
//  Created by Wojciech Piatkowski on 07/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import Foundation
import WebKit

var tipserEnvToTipserHostname = [
    TipserEnv.prod: "www.tipser.com",
    TipserEnv.stage: "t3-stage.tipser.com",
    TipserEnv.dev: "t3-dev.tipser.com"
]

class TipserWebpage {
    let webView : WKWebView
    let tipserTokenName : String = "tipserToken"
    let tipserTokenAnonymousFlagName : String = "tipserTokenAnonymous"
    var needRefresh = false
    var tipserEnv : TipserEnv
    
    init(posId: String, tipserEnv: TipserEnv){
        webView = WKWebView();
        self.tipserEnv = tipserEnv
    }
    
    func getToken(onComplete : @escaping (String?) -> Void ){
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies{ cookies in
            var tipserToken : String?
            for cookie in cookies {
                if (cookie.name == self.tipserTokenName){
                    tipserToken = cookie.value
                }
            }
            onComplete(tipserToken)
        }
    }
    
    func setToken(token: String, onComplete: @escaping ()->Void){
        let tipserToken = HTTPCookie(properties: [
            .domain: self.getHostname(),
            .path: "/",
            .name: self.tipserTokenName,
            .value: token,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!
        let anonymousTokenFlag = HTTPCookie(properties: [
            .domain: self.getHostname(),
            .path: "/",
            .name: self.tipserTokenAnonymousFlagName,
            .value: "1",
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!
    

        webView.configuration.websiteDataStore.httpCookieStore.setCookie(tipserToken){
            self.webView.configuration.websiteDataStore.httpCookieStore.setCookie(anonymousTokenFlag){
                onComplete()
            }
        }
    }
    
    func getCheckoutUrl(posId: String) -> String{
        let url = self.getBaseUrl() + "/wi/\(posId)/checkout"
        print(url)
        return url
    }
    
    func goToCheckout(posId: String) -> Void {
        let request = URLRequest(url: URL(string: self.getCheckoutUrl(posId: posId))!)
        webView.load(request)
    }
    
    private func getHostname() -> String {
        return tipserEnvToTipserHostname[self.tipserEnv]!
    }
    
    private func getBaseUrl() -> String {
        return "https://\(self.getHostname())"
    }
}

extension WKWebView {

enum PrefKey {
    static let cookie = "cookies"
}

func writeDiskCookies(for domain: String, completion: @escaping () -> ()) {
    fetchInMemoryCookies(for: domain) { data in
        print("write data", data)
        UserDefaults.standard.setValue(data, forKey: PrefKey.cookie + domain)
        completion();
    }
}


 func loadDiskCookies(for domain: String, completion: @escaping () -> ()) {
    if let diskCookie = UserDefaults.standard.dictionary(forKey: (PrefKey.cookie + domain)){
        fetchInMemoryCookies(for: domain) { freshCookie in

            let mergedCookie = diskCookie.merging(freshCookie) { (_, new) in new }

            for (_, cookieConfig) in mergedCookie {
                let cookie = cookieConfig as! Dictionary<String, Any>

                var expire : Any? = nil

                if let expireTime = cookie["Expires"] as? Double{
                    expire = Date(timeIntervalSinceNow: expireTime)
                }

                let newCookie = HTTPCookie(properties: [
                    .domain: cookie["Domain"] as Any,
                    .path: cookie["Path"] as Any,
                    .name: cookie["Name"] as Any,
                    .value: cookie["Value"] as Any,
                    .secure: cookie["Secure"] as Any,
                    .expires: expire as Any
                ])

                self.configuration.websiteDataStore.httpCookieStore.setCookie(newCookie!)
            }

            completion()
        }

    }
    else{
        completion()
    }
}

func fetchInMemoryCookies(for domain: String, completion: @escaping ([String: Any]) -> ()) {
    var cookieDict = [String: AnyObject]()
    WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
        for cookie in cookies {
            if cookie.domain.contains(domain) {
                cookieDict[cookie.name] = cookie.properties as AnyObject?
            }
        }
        completion(cookieDict)
    }
}}
