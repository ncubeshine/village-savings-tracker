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
                Color.red
                    .ignoresSafeArea()
           
            VStack {
                Text("Welcome to")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
                Image("Applogo")
                    .resizable()
                    .frame(width: 400, height: 400)
                    .imageScale(.medium)
                    .foregroundStyle(.tint)
                Spacer()
                
                Text("UBUNTUFUND SAVINGS TRACKER")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                Spacer()
                
              
                NavigationLink{
                    //descriptionPage()
                } label: {
                    Text("->")
                        .font(.largeTitle)
                        .foregroundStyle(.mint)
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
