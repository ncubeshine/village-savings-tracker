//
//  description page.swift
//  village savings app
//
//  Created by Shine Ncube on 10/17/25.
//

import SwiftUI

struct descriptionPage: View {
    var body: some View {
        ZStack{
            Color.cyan
                .ignoresSafeArea()
            
            Text("Communities always have challenges (e.g human error, lack of consistence, time consumed ) when it comes to keeping  track of  savings progress as a result UBUNTUFUND SAVINGS TRACKER is here to save the purpose  of helping the local savings group(mukando/stokvel) track their contributions, payouts and the interests earned")
                .font(.largeTitle)
        }
        
        
    }
}

#Preview {
 descriptionPage()
}
