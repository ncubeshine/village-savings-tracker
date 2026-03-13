//
//  ContentView.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Color.orange.opacity(0.3)
                    .ignoresSafeArea()
                    
           
                VStack (spacing: 50){
            Text("Welcome to")
                        .font(.title)
                    .fontWeight(.bold)
                    
                    Image("applogo")
                        .resizable()
                        .frame(width: 350, height: 350)
                        .imageScale(.medium)
                
               Text(" Your Savings, Your Future One Coin at a Time.")
                    .fontWeight(.bold)
                    .font(.headline)
                
                Spacer()
                
              
                NavigationLink{
                    descriptionPage()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .padding()
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
            }
            .padding()
           
                
            }
        }
        }
    }
}

#Preview {
    ContentView()
}
