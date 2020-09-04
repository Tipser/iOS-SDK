//
//  File.swift
//  TipserSDK
//
//  Created by Wojciech Piatkowski on 07/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

public struct TipserCheckout: UIViewRepresentable{
    private var tipserSDK : TipserSDK;
    private var webpage : TipserWebpage;
    
    public init(tipserSDK: TipserSDK){
        self.tipserSDK = tipserSDK
        webpage = tipserSDK.getTipserWebpage()
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        self.webpage.goToCheckout(posId: self.tipserSDK.getPosId())
        return self.webpage.webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        let webPage = self.tipserSDK.getTipserWebpage()
        if (webPage.needRefresh){
            webPage.needRefresh = false
            let posId = self.tipserSDK.getPosId();
            webPage.goToCheckout(posId: posId)
        }
    }
}
