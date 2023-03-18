//
//  PrivacyPolicyView.swift
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-03-18.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("\n\nwe dont sell your data 👍👍👍\n\n\n")
                Text("**Full**\n- Device Model\n- Device iOS Version\n- Whether it is your first launch or not\n- Language Region\n- Anonymized crash logs, IF you click \"report to developer\".\n- App version (for updates)\n\n**Limited**\n- App version (for updates)\n- Whether it is your first launch or not\n\n**None**\nNo HTTP requests ever sent.")
            }
        }
            .navigationTitle("Privacy Policy")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
