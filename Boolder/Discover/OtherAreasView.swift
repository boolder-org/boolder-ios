//
//  OtherAreasView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 19/12/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct OtherAreasView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HStack {
                        Spacer()
                        Image(systemName: "hourglass")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, alignment: .center)
                            .foregroundColor(.gray)
                            .padding(.vertical, 32)
                        Spacer()
                    }
                        
                    Text("other_areas.p1").font(.body)
                    
                    Text("other_areas.p2").font(.body)
                    
                    Button(action: {
                        if let url = mailToURL {
                          UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(alignment: .center, spacing: 16) {
                            Spacer()
                            Text("other_areas.contact_button")
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .fixedSize(horizontal: true, vertical: true)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                       .background(Color(UIColor.systemBackground))
                       .foregroundColor(Color(UIColor.systemGreen))
                       .cornerRadius(8)
                       .overlay(
                           RoundedRectangle(cornerRadius: 8)
                               .stroke(Color(UIColor.systemGreen), lineWidth: 2)
                       )
                        .padding(.vertical, 32)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .navigationBarTitle(Text("other_areas.title"), displayMode: .inline)
        }
    }
    
    var mailToURL: URL? {
        let recipient = "hello@boolder.com"
        let subject = "Hello :)".stringByAddingPercentEncodingForRFC3986() ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        
        let body = [
            "",
            "",
            "------",
            "Boolder \(appVersion ?? "") (\(buildNumber ?? ""))",
            "iOS \(UIDevice.current.systemVersion)",
        ]
        .map{$0.stringByAddingPercentEncodingForRFC3986() ?? ""}
        .joined(separator: "%0D%0A")
        
        return URL(string: "mailto:\(recipient)?subject=\(subject)&body=\(body)")
    }
}

// https://useyourloaf.com/blog/how-to-percent-encode-a-url-string/
extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}

struct OtherAreasView_Previews: PreviewProvider {
    static var previews: some View {
        OtherAreasView()
    }
}
