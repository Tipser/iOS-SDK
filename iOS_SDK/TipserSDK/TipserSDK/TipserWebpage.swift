//
//  TipserWebpage.swift
//  TipserSDK
//
//  Created by Wojciech Piatkowski on 07/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import Foundation
import WebKit

let tipserHostname : String = "www.tipser.com"

public class TipserWebpage {
    let webView : WKWebView
    let baseUrl : String = "https://\(tipserHostname)"
    let tipserTokenName : String = "tipserToken"
    var needRefresh = false
    
    init(posId: String){
        webView = WKWebView();
        let request = URLRequest(url: URL(string: getCheckoutUrl(posId: posId))!)
        webView.load(request)
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
        let cookie = HTTPCookie(properties: [
            .domain: tipserHostname,
            .path: "/",
            .name: self.tipserTokenName,
            .value: token,
            .secure: "TRUE",
            .expires: NSDate(timeIntervalSinceNow: 31556926)
        ])!

        webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie){
            onComplete()
        }
    }
    
    func getCheckoutUrl(posId: String) -> String{
        let url = baseUrl + "/wi/\(tipserSDK.getPosId())/checkout"
        print(url)
        return url
    }
    
    func goToCheckout(posId: String) -> Void {
        let request = URLRequest(url: URL(string: self.getCheckoutUrl(posId: posId))!)
        webView.load(request)
    }
}
