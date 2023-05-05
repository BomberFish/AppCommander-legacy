//
//  PackageCreditsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-26.
//

import SwiftUI

struct PackageCreditsView: View {
    
    fileprivate var packages: [Package] = [
        Package(name: "BomberFish/AbsoluteSolver-iOS", link: "https://github.com/BomberFish/AbsoluteSolver-iOS", symbol: "move.3d"),
        Package(name: "BomberFish/DirtyCowKit", link: "https://github.com/BomberFish/DirtyCowKit", symbol: "ant"),
        Package(name: "mhdhejazi/Dynamic", link: "https://github.com/mhdhejazi/Dynamic", symbol: nil),
        Package(name: "markrenaud/FilePicker", link: "https://github.com/markrenaud/FilePicker", symbol: "folder"),
        Package(name: "Cindori/FluidGradient", link: "https://github.com/Cindori/FluidGradient", symbol: "water.waves"),
        Package(name: "BomberFish/LocalConsole", link: "https://github.com/BomberFish/LocalConsole", symbol: "terminal"),
        Package(name: "joekndy/MarqueeText", link: "https://github.com/joekndy/MarqueeText", symbol: "textformat"),
        Package(name: "SerenaKit/PrivateKits", link: "https://github.com/SerenaKit/PrivateKits", symbol: nil)
    ]
    var body: some View {
        List {
            ForEach(packages) {package in
                PackageCell(package: package)
            }
        }
        // .background(GradientView())
                .listRowBackground(Color.clear)
        //.listStyle(.sidebar)
        .navigationTitle("Swift Packages")
    }
}

fileprivate struct Package: Equatable, Identifiable {
    var id = UUID()
    let name: String
    let link: String
    let symbol: String?
}

fileprivate struct PackageCell: View {
    let package: Package
    var body: some View {
        HStack {
            Button(action: {UIApplication.shared.open(URL(string: package.link)!)}, label: {Label(package.name, systemImage: package.symbol ?? "shippingbox")})
        }
    }
}

struct PackageCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        PackageCreditsView()
    }
}
