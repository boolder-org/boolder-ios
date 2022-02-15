//
//  TopAreasDryFast.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 14/02/2022.
//  Copyright © 2022 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct TopAreasDryFast: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.openURL) var openURL
    
    @State var presentArea = false
    let gray = Color(red: 107/255, green: 114/255, blue: 128/255)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading) {
                    
                    Divider()
                    
                    ForEach(areas) { area in
                        NavigationLink(
                            destination: AreaView(),
                            isActive: $presentArea,
                            label: {
                                HStack {
                                    Text(area.name)
                                        .font(.body)
                                        .foregroundColor(Color.appGreen)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    dataStore.areaId = area.id
                                    dataStore.filters = Filters()
                                    presentArea = true
                                }
                            }
                        )
                        
                        Divider()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                .padding(.vertical, 8)
                
                Text("Ces secteurs sèchent plus vite que la moyenne, grâce à leur exposition au soleil ou au vent.")
                    .font(.body)
                    .foregroundColor(gray)
                    
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill").font(.body)
                    Text("Ne grimpez pas si la roche est encore humide, vous risquez de l'abîmer.").font(.body)
                    Spacer()
                }
                    .foregroundColor(Color.orange.opacity(0.8))
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
                
                HStack(alignment: .top, spacing: 4) {
                    Text("Lien utile :")
                        .foregroundColor(gray)
                    
                    Button(action: {
                        openURL(URL(string: "https://www.facebook.com/people/Bleau-Meteo/100055389702633/")!)
                    }) {
                        Text("Bleau Météo")
                            .foregroundColor(Color.appGreen)
                    }
                }
                
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationTitle("Sèche vite")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    var areas: [Area] {
        [2,7,16,15,10].map{dataStore.area(withId:$0)!}.sorted {
            $0.name.folding(options: .diacriticInsensitive, locale: .current) < $1.name.folding(options: .diacriticInsensitive, locale: .current)
        }
    }
}

struct TopAreasDryFast_Previews: PreviewProvider {
    static var previews: some View {
        TopAreasDryFast()
    }
}
