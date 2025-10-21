//
//  description page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

struct descriptionPage: View {
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()
                VStack (spacing: 50){
                    
                    Text("Communities always have challenges (e.g human error, lack of consistence, time consumed ) when it comes to keeping  track of  savings progress as a result UbuntuFund Savings Tracker is here to save the purpose  of helping the local savings group(mukando/stokvel) track their contributions, payouts and the interests earned")
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .font(.headline)
                       //.padding(.trailing)
                    
                    
                    
                    //NavigationLink {
                       // homePage()
                    //} label: {
                    NavigationLink(destination: HomePage()) {
                        Text("Get Started")
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                        
                           
                        
                    }
                    
                }
            }
        }
        
        }
        
        
    


#Preview {
 descriptionPage()
}
