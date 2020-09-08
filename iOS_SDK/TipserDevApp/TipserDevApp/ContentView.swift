//
//  ContentView.swift
//  TipserDevApp
//
//  Created by Patryk Peas on 06/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import SwiftUI
import TipserSDK
import NotificationBannerSwift

struct ContentView: View{
    @State private var addingProduct = false
    @State private var banner : BaseNotificationBanner?;
    @State private var numberOfProducts : Int = 0;
    
    init() {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    func showBanner(bannerStyle: BannerStyle, title: String, subtitle: String? = nil){
        DispatchQueue.main.async {
            if (self.banner != nil){
                self.banner?.dismiss()
            }
            
            self.banner = NotificationBanner(title: title, subtitle: subtitle, style: bannerStyle)
            self.banner!.show(bannerPosition: .bottom)
        }
    }
    
    func showSuccessBanner(){
        self.showBanner(bannerStyle: .info, title: "Product added")
    }
    
    func showErrorBanner(){
        self.showBanner(bannerStyle: .danger, title: "Ups... Something went wrong.", subtitle: "Product couldn't not be added")
    }
    
    func onAddToProductClick(){
        self.addingProduct = true;
        tipserSDK.addProduct(productId: "55a65f4878415534087b3903", onComplete: {
            self.addingProduct = false;
            self.showSuccessBanner();
            self.fetchShoppingCart();
        }, onError: {
            self.showErrorBanner();
            self.addingProduct = false;
        })
    }
    
    func fetchShoppingCart(){
        tipserSDK.fetchShoppingCart(onComplete: { shoppingCart in
            self.numberOfProducts = shoppingCart.numberOfProducts
        }, onError: {
            print("fetching shopping cart failed")
        })
    }
    
    var body: some View {    
        return NavigationView{
            VStack(){
                Button(action: onAddToProductClick) {
                    Text("Add Product")
                        .font(.largeTitle)
                    }
                .padding(.vertical)
                .disabled(addingProduct)
                
                NavigationLink(destination: CheckoutView().onAppear(){
                    self.banner?.dismiss()
                }) {
                    Text("Checkout").font(.largeTitle)
                }
                .padding(.vertical)
                .disabled(addingProduct)
                
                Text("Products in cart: \(self.numberOfProducts)").font(.footnote)
            }
            .navigationBarTitle("Shop")
            .onAppear(){
                self.fetchShoppingCart();
            }
        }
    }
}

struct CheckoutView: View {
    var body: some View {
        return VStack(){
            TipserCheckout(tipserSDK: tipserSDK)
        }.onAppear {
            tipserSDK.getToken(){ token in
                print("Checkout open. Token is \(token)")
            }
        }
        .navigationBarTitle("Checkout", displayMode: .inline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
