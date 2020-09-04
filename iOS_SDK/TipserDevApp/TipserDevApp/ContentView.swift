//
//  ContentView.swift
//  TipserDevApp
//
//  Created by Patryk Peas on 06/12/2019.
//  Copyright © 2019 Tipser. All rights reserved.
//

import SwiftUI
import TipserSDK

struct ContentView: View{
    @State private var addingProduct = false
    
    init() {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
    }
    
    var body: some View {    
        return NavigationView{
            VStack(){
                Button(action: {
                    self.addingProduct = true;
                    tipserSDK.addProduct(productId: "55a65f4878415534087b3903") { () in
                        print("UI - Product added!")
                        self.addingProduct = false;
                    }
                }) {
                    Text("Add Product")
                        .font(.largeTitle)
                }
                .padding(.vertical)
                .disabled(addingProduct)
                NavigationLink(destination: CheckoutView()) {
                    Text("Checkout")
                    .font(.largeTitle)
                }.padding(.vertical).disabled(addingProduct)
            }
            .navigationBarTitle("Shop")        
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
