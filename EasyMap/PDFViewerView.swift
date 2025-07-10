//
//  PDFViewerView.swift
//  EasyMap
//
//  Created by Lorenzo Campagna on 10/07/25.
//

import SwiftUI

struct PDFViewerView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Chiudi") {
                    dismiss()
                }
                .padding()
                .foregroundColor(.blue)
                Spacer()
            }

            Divider()

            PDFKitView(url: url)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
