//
//  TipserAPI.swift
//  TipserSDK
//
//  Created by Wojciech Piatkowski on 07/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import Foundation

func doGetRequestToTipser(uri: String, onComplete : @escaping (String)->Void, onError : @escaping ()->Void){
    doRequestToTipser(uri: uri, parameters: nil, tipserToken: nil, method: "GET", onComplete: { data in
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            onComplete(dataString)
        }
    }, onError: onError)
}
    
func doRequestToTipser(uri : String , parameters: [String: Any]?, tipserToken: String?, method: String?, onComplete: ((Data?)->Void)? = nil, onError: (()->Void)? = nil){
    let url = URL(string: "https://t3-prod-api.tipser.com" + uri)!
    var request = URLRequest(url: url)
    print(request)
    
    let method = method != nil ? method: "GET"
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
                onComplete(data)
            }
        }
    }
    task.resume()
}

