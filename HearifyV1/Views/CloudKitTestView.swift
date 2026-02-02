//
//  CloudKitTestView.swift
//  HearifyV1
//
//  Simple test view to try out CloudKit linking
//  You can access this from anywhere to test the feature!
//

import SwiftUI

struct CloudKitTestView: View {
    @State private var showLinking = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "icloud.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)

                Text("CloudKit Test")
                    .font(.title.bold())

                Text("Click the button below to test the audiologist linking feature!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()

                Button {
                    showLinking = true
                } label: {
                    Label("Link with Audiologist", systemImage: "person.badge.plus")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("CloudKit Test")
            .sheet(isPresented: $showLinking) {
                ClinicianLinkingView()
            }
        }
    }
}

#Preview {
    CloudKitTestView()
}
