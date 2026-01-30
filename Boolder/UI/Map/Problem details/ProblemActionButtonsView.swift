//
//  ProblemActionButtonsView.swift
//  Boolder
//
//  Created by Nicolas Mondollot on 15/01/2026.
//  Copyright © 2026 Nicolas Mondollot. All rights reserved.
//

import SwiftUI

struct ProblemActionButtonsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(MapState.self) private var mapState: MapState
    @FetchRequest(entity: Favorite.entity(), sortDescriptors: []) var favorites: FetchedResults<Favorite>
    @FetchRequest(entity: Tick.entity(), sortDescriptors: []) var ticks: FetchedResults<Tick>
    
    @Binding var problem: Problem
    let withHorizontalPadding: Bool
    let showCircuitButton: Bool
    
    @State private var presentSaveActionsheet = false
    @State private var presentSharesheet = false
    @State private var presentCircuitActionsheet = false
    
    init(problem: Binding<Problem>, withHorizontalPadding: Bool = true, showCircuitButton: Bool = true) {
        self._problem = problem
        self.withHorizontalPadding = withHorizontalPadding
        self.showCircuitButton = showCircuitButton
    }
    
    private var saveManager: ProblemSaveManager {
        ProblemSaveManager(
            problem: problem,
            favorites: favorites,
            ticks: ticks,
            managedObjectContext: managedObjectContext
        )
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 8) {
                
                if problem.bleauInfoId != nil && problem.bleauInfoId != "" {
                    Button(action: {
                        openURL(URL(string: "https://bleau.info/a/\(problem.bleauInfoId ?? "").html")!)
                    }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "info.circle")
                            Text("Bleau.info").fixedSize(horizontal: true, vertical: true)
                        }
                        .modify {
                            if #available(iOS 26, *) {
                                $0
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                            } else {
                                $0
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.buttonStyle(.glassProminent)
                        } else {
                            $0
                                .buttonStyle(Pill(fill: true))
                        }
                    }
                }
                
                if showCircuitButton, let circuitId = problem.circuitId, let circuit = Circuit.load(id: circuitId) {
                    Button(action: {
                        presentCircuitActionsheet = true
                    }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image("circuit")
                            Text("problem.action.see_circuit").fixedSize(horizontal: true, vertical: true)
                        }
                        .modify {
                            if #available(iOS 26, *) {
                                $0
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                            } else {
                                $0
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.buttonStyle(.glass)
                        } else {
                            $0
                                .buttonStyle(Pill())
                        }
                    }
                    .actionSheet(isPresented: $presentCircuitActionsheet) {
                        ActionSheet(
                            title: Text(circuit.color.longName),
                            buttons: [
                                .default(Text(mapState.selectedCircuit?.id == circuitId ? "problem.action.hide_circuit_on_map" : "problem.action.see_circuit_on_map")) {
                                    if mapState.selectedCircuit?.id == circuitId {
                                        mapState.unselectCircuit()
                                    } else {
                                        mapState.selectCircuit(circuit)
                                    }
                                },
                                .cancel()
                            ]
                        )
                    }
                }
                
                if problem.variants.count > 1 {
                    Menu {
                        ForEach(problem.variants.sorted { $0.grade > $1.grade }) { variant in
                            Button {
                                mapState.selectProblem(variant)
                            } label: {
                                HStack {
                                    Text("\(variant.grade.string) - \(variant.localizedName)")
                                    if variant.id == problem.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "arrow.trianglehead.branch")
                            Text(String(format: NSLocalizedString(problem.variants.count == 1 ? "problem.startgroup.variants.singular" : "problem.startgroup.variants.plural", comment: ""), problem.variants.count))
                                .fixedSize(horizontal: true, vertical: true)
                        }
                        .modify {
                            if #available(iOS 26, *) {
                                $0
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 4)
                            } else {
                                $0
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0.buttonStyle(.glass)
                        } else {
                            $0
                                .buttonStyle(Pill())
                        }
                    }
                }
                
                Button(action: {
                    presentSaveActionsheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: (saveManager.isFavorite() || saveManager.isTicked()) ? "bookmark.fill" : "bookmark")
                        Text((saveManager.isFavorite() || saveManager.isTicked()) ? "problem.action.saved" : "problem.action.save")
                            .fixedSize(horizontal: true, vertical: true)
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        } else {
                            $0
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                            .buttonStyle(Pill())
                    }
                }
                .actionSheet(isPresented: $presentSaveActionsheet) {
                    ActionSheet(title: Text("problem.action.save"), buttons: saveManager.saveButtons())
                }
                
                Button(action: {
                    presentSharesheet = true
                }) {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .modify {
                        if #available(iOS 26, *) {
                            $0
                                .padding(.vertical, 2)
                                .padding(.horizontal, 4)
                        } else {
                            $0
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .modify {
                    if #available(iOS 26, *) {
                        $0.buttonStyle(.glass)
                    } else {
                        $0
                            .buttonStyle(Pill())
                    }
                }
                .sheet(isPresented: $presentSharesheet,
                       content: {
                    ActivityView(activityItems: [boolderURL] as [Any], applicationActivities: nil)
                })
            }
            .modify {
                if withHorizontalPadding {
                    $0
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                } else {
                    $0
                }
            }
        }
        .scrollClipDisabled()
    }
    
    private var boolderURL: URL {
        URL(string: "https://www.boolder.com/\(NSLocale.websiteLocale)/p/\(String(problem.id))")!
    }
}

