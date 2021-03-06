//
//  TipserAPI.swift
//  TipserSDK
//
//  Created by Wojciech Piatkowski on 07/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import Foundation

private var tipserEnvToApiHostname = [
    TipserEnv.prod: "t3-prod-api.tipser.com",
    TipserEnv.stage: "t3-stage-api.tipser.com",
    TipserEnv.dev: "t3-dev-api.tipser.com"
]

struct TipserApi {
    var tipserEnv: TipserEnv
    
    init(tipserEnv: TipserEnv){
        self.tipserEnv = tipserEnv
    }
    
    func doRequestToApi(uri : String , parameters: [String: Any]? = nil, tipserToken: String? = nil, method: String = "GET", onComplete: ((Data?, HTTPURLResponse?)->Void)? = nil, onError: (()->Void)? = nil){
        let urlBase = "https://\(tipserEnvToApiHostname[self.tipserEnv]!)"
        let url = "\(urlBase)\(uri)"
        doRequestToTipser(url: url, parameters: parameters, tipserToken: tipserToken, method: method, onComplete: onComplete, onError: onError)
    }
    
    func addProduct(posId: String, productId: String, tipserToken: String, onComplete: (()->Void)? = nil, onError: (()->Void)? = nil){
        let uri = "/v3/shoppingcart/items"
        let parameters : [String: Any] = [
            "productId": productId,
            "posId": posId,
            "posArtile": "tipser",
            "quantity": 1,
            "posData": "",
        ]
        
        self.doRequestToApi(uri: uri, parameters: parameters, tipserToken: tipserToken, method: "POST", onComplete: { (data, urlResponse) in
            let statusCode : Int = urlResponse?.statusCode ?? 200;
            let isSuccessStatusCode = statusCode >= 200 && statusCode < 400
            if (onComplete != nil && isSuccessStatusCode){
                onComplete!()
            }else if (onError != nil && !isSuccessStatusCode){
                onError!()
            }
        }, onError: {
            if (onError != nil){
                onError!();
            }
        })
    }
    
    func fetchShoppingCart(tipserToken: String, onComplete: (@escaping (ShoppingCart)->Void), onError: (()->Void)? = nil){
        let uri = "/v3/shoppingcart"
        self.doRequestToApi(uri: uri, tipserToken: tipserToken, method: "GET", onComplete: { (data, urlResponse) in
            let statusCode : Int = urlResponse?.statusCode ?? 200;
            let isSuccessStatusCode = statusCode >= 200 && statusCode < 400
            if (isSuccessStatusCode && data != nil){
                do {
                    let shoppingCart = try JSONDecoder().decode(ShoppingCart.self, from: data!)
                    onComplete(shoppingCart)
                } catch let error {
                    print(error);
                    if let onError = onError {
                        onError();
                    }
                }
            }else {
                if let onError = onError {
                    onError();
                }
            }
        }, onError: {
            if let onError = onError {
                onError();
            }
        })
    }
    
    func fetchNewToken(onComplete : @escaping (String?)->Void){
        let uri = "/v3/auth/anonymousToken"
        self.doRequestToApi(uri: uri, onComplete: { (data, urlResponse) in
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let clearTokenValue = dataString.replacingOccurrences(of: "\"", with: "")
                onComplete(clearTokenValue)
            }
        }, onError: {
            onComplete(nil)
        })
    }
}

public struct ShoppingCart : Codable {
    public let numberOfProducts: Int
}
    
private func doRequestToTipser(url : String , parameters: [String: Any]?, tipserToken: String?, method: String, onComplete: ((Data?, HTTPURLResponse?)->Void)? = nil, onError: (()->Void)? = nil){
    let properUrl = URL(string: url)
    var request = URLRequest(url: properUrl!)
    print(request)
    
    request.httpMethod = method
    
    // if parameters are set, assume its JSON content type
    if (parameters != nil){
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
    }
        
    if (tipserToken != nil){
        request.addValue("Bearer \(tipserToken!)", forHTTPHeaderField: "authorization")
    }
    
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("error: \(error)")
            if let onError = onError {
                onError()
            }
        } else {
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("data: \(dataString)")
            }
            if let onComplete = onComplete{
                onComplete(data, response as? HTTPURLResponse)
            }
        }
    }
    task.resume()
}
