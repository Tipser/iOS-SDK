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
    public init(){
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return tipserSDK.getTipserWebpage().webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        let webPage = tipserSDK.getTipserWebpage()
        if (webPage.needRefresh){
            webPage.needRefresh = false
            let posId = tipserSDK.getPosId();
            webPage.goToCheckout(posId: posId)
        }
    }
}
