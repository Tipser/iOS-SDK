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
    var body: some View {    
        return NavigationView{
            VStack(){
                Button(action: {
                    tipserSDK.addProduct(productId: "5da5c5249af3ba00010b84fc")
                }) {
                    Text("Add Product")
                        .font(.largeTitle)
                }
                .padding(.vertical)
                NavigationLink(destination: CheckoutView()) {
                    Text("Checkout")
                    .font(.largeTitle)
                }.padding(.vertical)
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
