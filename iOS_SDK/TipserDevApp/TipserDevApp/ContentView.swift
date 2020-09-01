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
        }
    }
}

struct CheckoutView: View {
    var body: some View {
        TipserCheckout()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
