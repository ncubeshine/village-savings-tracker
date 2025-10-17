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
                Color.cyan
                    .ignoresSafeArea()
           
            VStack {
                //Text("Welcome to")
                   // .fontWeight(.bold)
                    //.font(.largeTitle)
                Spacer()
                Image("Applogo")
                    .resizable()
                    .frame(width: 600, height: 600)
                    .imageScale(.medium)
                    .foregroundStyle(.tint)
                
                
               // Text("UBUNTUFUND SAVINGS TRACKER")
                    //.fontWeight(.bold)
                    //.font(.largeTitle)
                
                
              
                NavigationLink{
                    //descriptionPage()
                } label: {
                    Text("->")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
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
