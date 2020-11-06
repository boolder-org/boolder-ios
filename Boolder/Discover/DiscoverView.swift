//
//  DiscoverView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 27/10/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.presentationMode) var presentationMode // required because of a bug with iOS 13: https://stackoverflow.com/questions/58512344/swiftui-navigation-bar-button-not-clickable-after-sheet-has-been-presented
    
    @State var presentArea = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text("Fontainebleau")
                            .font(.title2).bold()
                        
                        Divider()
                        
//                        NavigationLink(
//                            destination: AreaView(),
//                            label: {
//                                HStack {
//                                    Text("Rocher Canon")
//                                        .font(.body)
//                                        .foregroundColor(Color.green)
//                                    Spacer()
//                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                }
//
//                            }
//                        )
//
//                        Divider()
//
//                        NavigationLink(
//                            destination: AreaView(),
//                            label: {
//                                HStack {
//                                    Text("Cuvier")
//                                        .font(.body)
//                                        .foregroundColor(Color.green)
//                                    Spacer()
//                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
//                                }
//                            }
//                        )
//
//                        Divider()
                        
                        NavigationLink(
                            destination: EmptyView(),
                            label: {
                                HStack {
                                    Text("Voir les secteurs à Fontainebleau")
                                        .font(.body)
                                        .foregroundColor(Color.green)
                                    Spacer()
                                    Image(systemName: "chevron.right").foregroundColor(Color(UIColor.lightGray))
                                }
                            }
                        )
                        
                        Divider()
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    VStack {
                        VStack(alignment: .leading) {
                            Text("Idéal pour débuter")
                                .font(.title2).bold()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                    
                                        VStack(alignment: .leading) {
                                            Image("cover-rocher-canon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("130 voies de niveau débutant")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .padding(.leading, 16)
                                        .onTapGesture {
                                            self.dataStore.areaId = 1
                                            presentArea = true
                                        }
                                    }
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-isatis")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("90 voies de niveau débutant")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .onTapGesture {
//                                            self.dataStore.areaId =
//                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-cul-de-chien")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("70 voies de niveau débutant")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .onTapGesture {
                                            self.dataStore.areaId = 2
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Envie de performer ?")
                                .font(.title2).bold()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 0) {
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-cuvier")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("400 voies entre 6a et 8c+")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .onTapGesture {
                                            self.dataStore.areaId = 4
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-rocher-canon")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("300 voies entre 6a et 8c")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .onTapGesture {
                                            self.dataStore.areaId = 1
                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    
                                    NavigationLink(destination: AreaView(), isActive: $presentArea) {
                                        VStack(alignment: .leading) {
                                            Image("cover-isatis")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 255, height: 155)
                                                .cornerRadius(16)
                                            Text("250 voies entre 6a et 8c")
                                                .font(.subheadline)
                                                .foregroundColor(Color.gray)
                                        }
                                        .onTapGesture {
//                                            self.dataStore.areaId =
//                                            presentArea = true
                                        }
                                    }
                                    .padding(.leading, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                        }
                            
                    }
                }
                .navigationBarTitle(Text("On grimpe où ?"))
            }
        }
//        .navigationViewStyle(StackNavigationViewStyle()) // FIXME: there is a weird bug when using StackNavigationViewStyle() on iPhone: the sheets get dismissed automatically the first time they are presented. Sometimes but not always. It seems to happen only when I try to present the sheet a couple of seconds after the app launch, which seems to indicate that the app is not properly loaded? maybe it's still setting up the navigationview "style"?? Anywa, I figured it's easier to just avoid using StackNavigationViewStyle() for now :)
        .accentColor(Color.green)
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
