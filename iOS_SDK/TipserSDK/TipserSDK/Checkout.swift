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
        refreshOrOpenIfNeeded()
        
        return webpage.webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        refreshOrOpenIfNeeded()
    }
    
    private func refreshOrOpenIfNeeded(){
        let posId = tipserSDK.getPosId()
        if (!webpage.isOnCheckout(posId: posId) || tipserSDK.checkoutNeedsRefresh){
            tipserSDK.checkoutNeedsRefresh = false;
            webpage.goToCheckout(posId: posId)
        }
    }
}
