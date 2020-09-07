import Foundation
import WebKit

public class TipserSDK {
    let version: String = "0.0.1"
    var posId: String = ""
    var tipserWebpage: TipserWebpage?
    var isAddingProduct = false
    var tipserTokenCache : String?
    var tipserEnv: TipserEnv;
    var tipserApi: TipserApi;
    public var checkoutNeedsRefresh: Bool = false;
    
    public init(tipserEnv: TipserEnv = TipserEnv.prod) {
        self.tipserEnv = tipserEnv
        self.tipserApi = TipserApi(tipserEnv: tipserEnv)
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
    
    public func addProduct(productId: String, onComplete : @escaping ()->Void, onError: (()->Void)?){
        if (self.isAddingProduct){
            return
        }
        self.isAddingProduct = true
        
        
        self.forceGetToken() { tipserToken in
            if (tipserToken == nil){
                self.isAddingProduct = false
                return
            }
            self.tipserApi.addProduct(posId: self.posId, productId: productId, tipserToken: tipserToken!, onComplete: {
                self.isAddingProduct = false
                self.checkoutNeedsRefresh = true;
                onComplete()
            }, onError: {
                self.isAddingProduct = false
                if (onError != nil){
                    onError!()
                }
            })
        }
    }
    
    public func forceGetToken(onComplete : @escaping (String?)->Void ) -> Void{
        if (self.tipserTokenCache != nil){
            print("Token from cache", self.tipserTokenCache!)
            return onComplete(self.tipserTokenCache)
        }
        
        self.getToken(){ token in
            if token != nil{
                print("Token from webview")
                return onComplete(token)
            }
            print("Token from webview is nil!")
            self.tipserApi.fetchNewToken(){ newToken in
                if (newToken == nil){
                    print("Error: Token could not be fetched")
                    onComplete(nil)
                }
                DispatchQueue.main.async {
                    self.getTipserWebpage().setToken(token: newToken!){
                        print("Token saved in webview")
                        onComplete(newToken)
                        //self.tipserTokenCache = clearTokenValue;
                    }
                }
            }
            
        }
    }
    
    public func getWebView() -> WKWebView{
        return self.getTipserWebpage().webView
    }
    
    public func getToken(onComplete: @escaping (String?)->Void) -> Void {
        self.getTipserWebpage().getToken(){ token in
            onComplete(token)
        }
    }
    
    func getTipserWebpage() -> TipserWebpage {
        if (self.tipserWebpage == nil){
            self.tipserWebpage = TipserWebpage(posId: self.getPosId(), tipserEnv: self.tipserEnv)
        }
        return self.tipserWebpage!
    }
}
