//
//  CircuitHelpView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 05/05/2020.
//  Copyright © 2020 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

let circuitSize: CGFloat = 28

struct CircuitHelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    Text("circuit_help.title")
                        .font(.largeTitle)
                        .foregroundColor(Color(.systemGreen))
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 32)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("circuit_help.circuits.p1").font(.body)
                    
                    Text("circuit_help.circuits.p2").font(.body)
                    
                    CircuitLevelMatrix()
                        .padding(.trailing, 32)
                        .padding(.top, 16)
                    
                    Text("circuit_help.circuits.p3").font(.body)
                    
                    Text("circuit_help.numbers.title")
                        .font(.title)
                        .padding(.top, 32)
                    
                    Text("circuit_help.numbers.p1").font(.body)
                    
                    Image("yellow-circuit-start")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .padding(.top, 16)
                        
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(alignment: .center, spacing: 16) {
                            Spacer()
                            Text("circuit_help.got_it")
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .fixedSize(horizontal: true, vertical: true)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .buttonStyle(LargeButton())
                    .padding(.vertical, 32)
                }
            }
            .padding(32)
        }
    }
}

struct CircuitCellView: View {
    var noSpacer = false
    var color = Color(.clear)
    
    var body: some View {
        Group {
            Rectangle()
                .fill(color)
                .frame(width: circuitSize)
            if !noSpacer {
                Spacer()
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    func roundedBottom() -> some View {
        cornerRadius(circuitSize/2, corners: [.bottomLeft, .bottomRight])
    }
    
    func roundedTop() -> some View {
        cornerRadius(circuitSize/2, corners: [.topLeft, .topRight])
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CircuitHelpView_Previews: PreviewProvider {
    static var previews: some View {
        CircuitHelpView()
            .environmentObject(DataStore())
    }
}

struct CircuitLevelMatrix: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                RowLabelView(grade: "8")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true, color: Color(.black)).roundedTop()
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "7")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true, color: Color(.black))
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "6")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(color: Color(.systemRed)).roundedTop()
                    CircuitCellView(noSpacer: true, color: Color(.black)).roundedBottom()
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "5")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(color: Color(.systemBlue)).roundedTop()
                    CircuitCellView(color: Color(.systemRed)).roundedBottom()
                    CircuitCellView(noSpacer: true)
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "4")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView(color: Color(.systemOrange)).roundedTop()
                    CircuitCellView(color: Color(.systemBlue)).roundedBottom()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true)
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "3")
                
                HStack() {
                    CircuitCellView(color: Color(.systemYellow)).roundedTop()
                    CircuitCellView(color: Color(.systemOrange)).roundedBottom()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true)
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "2")
                
                HStack() {
                    CircuitCellView(color: Color(.systemYellow)).roundedBottom()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true)
                }
            }
            .frame(height: circuitSize)
            
            HStack {
                RowLabelView(grade: "1")
                
                HStack() {
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView()
                    CircuitCellView(noSpacer: true)
                }
            }
            .frame(height: circuitSize)
        }
    }
}

struct RowLabelView: View {
    var grade: String
    
    var body: some View {
        HStack {
            Text(grade).bold()
//            Text("a b c").foregroundColor(.gray)
        }
        .frame(width: 64)
    }
}
