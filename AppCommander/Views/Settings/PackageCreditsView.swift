//
//  PackageCreditsView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-26.
//

import SwiftUI

struct PackageCreditsView: View {
    
    fileprivate var packages: [Package] = [
        Package(name: "BomberFish/AbsoluteSolver-iOS", link: "https://github.com/BomberFish/AbsoluteSolver-iOS"),
        Package(name: "BomberFish/DirtyCowKit", link: "https://github.com/BomberFish/DirtyCowKit"),
        Package(name: "mhdhejazi/Dynamic", link: "https://github.com/mhdhejazi/Dynamic"),
        Package(name: "markrenaud/FilePicker", link: "https://github.com/markrenaud/FilePicker"),
        Package(name: "Cindori/FluidGradient", link: "https://github.com/Cindori/FluidGradient"),
        Package(name: "BomberFish/LocalConsole", link: "https://github.com/BomberFish/LocalConsole"),
        Package(name: "joekndy/MarqueeText", link: "https://github.com/joekndy/MarqueeText"),
        Package(name: "SerenaKit/PrivateKits", link: "https://github.com/SerenaKit/PrivateKits")
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
}

fileprivate struct PackageCell: View {
    let package: Package
    var body: some View {
        HStack {
            Button(action: {UIApplication.shared.open(URL(string: package.link)!)}, label: {Label(package.name, systemImage: "shippingbox")})
        }
    }
}

struct PackageCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        PackageCreditsView()
    }
}
