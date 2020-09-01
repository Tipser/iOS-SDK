import Foundation
import WebKit

public class TipserSDK {
    let version: String = "0.0.1"
    var posId: String = ""
    var tipserWebpage: TipserWebpage?
    var isAddingProduct = false
    var tipserTokenCache : String?
    
    public init() {
    }
    
    public func getVersion() -> String {
        return version;
    }
    

    public func getPosId() -> String {
        return posId;
    }
    
    public func setPosId(posId: String) -> Void {
        self.posId = posId;
    }
    
    public func addProduct(productId: String, onComplete : @escaping ()->Void ){
        if (self.isAddingProduct){
            return
        }
        self.isAddingProduct = true
        let uri = "/v3/shoppingcart/items"
        let parameters : [String: Any] = [
            "productId": productId,
            "posId": getPosId(),
            "posArtile": "tipser",
            "quantity": 1,
            "posData": "",
        ]
        
        self.getToken() { tipserToken in
            if (tipserToken == nil){
                self.isAddingProduct = false
                return
            }
            doRequestToTipser(uri: uri, parameters: parameters, tipserToken: tipserToken, method: "POST", onComplete: { data in
                self.isAddingProduct = false
                self.getTipserWebpage().needRefresh = true;
                onComplete()
            }, onError: {
                self.isAddingProduct = false
                onComplete()
            })
        }
    }
    
    public func getToken(onComplete : @escaping (String?)->Void ) -> Void{
        if (self.tipserTokenCache != nil){
            print("Token from cache", self.tipserTokenCache!)
            return onComplete(self.tipserTokenCache)
        }
        
        self.getTipserWebpage().getToken(){ token in
            if token != nil{
                print("Token from webview")
                return onComplete(token)
            }
            print("Token from webview is nil!")
                
            let uri = "/v3/auth/anonymousToken"
            doGetRequestToTipser(uri: uri, onComplete: { tokenString in
                let clearTokenValue = tokenString.replacingOccurrences(of: "\"", with: "")
                DispatchQueue.main.async {
                    self.getTipserWebpage().setToken(token: clearTokenValue){
                        print("Token saved in webview")
//                        self.tipserTokenCache = clearTokenValue;
                        onComplete(clearTokenValue)
                    }
                }
            }, onError: {
                onComplete(nil)
            })
        }
    }
    
    public func getWebView() -> WKWebView{
        return self.getTipserWebpage().webView
    }
    
    func getTipserWebpage() -> TipserWebpage {
        if (self.tipserWebpage == nil){
            self.tipserWebpage = TipserWebpage(posId: self.getPosId())
        }
        return self.tipserWebpage!
    }
}

public let tipserSDK = TipserSDK();
