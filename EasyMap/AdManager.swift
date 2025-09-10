//
//  AdManager.swift
//  EasyMap
//
//  Created by Studente on 10/09/25.
//

import SwiftUI
import Combine

@MainActor
final class AdManager: ObservableObject {
    static let shared = AdManager()

    // Interstitial (cap per avvio)
    @Published var isPresentingAd: Bool = false
    @Published private(set) var impressionsThisLaunch: Int = 0
    private let maxImpressionsPerLaunch = 2
    let minCloseSeconds = 5
    let autoDismissSeconds = 10
    private var pendingCompletion: (() -> Void)?

    // Rewarded (indipendente dal cap)
    @Published var isPresentingRewarded: Bool = false
    let rewardSeconds = 20
    private var pendingRewardCompletion: (() -> Void)?

    private init() {}

    // INTERSTITIAL
    func requestAd(then completion: @escaping () -> Void) {
        guard impressionsThisLaunch < maxImpressionsPerLaunch, !isPresentingAd else {
            completion()
            return
        }
        pendingCompletion = completion
        isPresentingAd = true
    }

    func finishAd() {
        guard isPresentingAd else { return }
        impressionsThisLaunch += 1
        isPresentingAd = false
        let action = pendingCompletion
        pendingCompletion = nil
        action?()
    }

    // REWARDED
    func requestRewardedAd(then completion: @escaping () -> Void) {
        pendingRewardCompletion = completion
        isPresentingRewarded = true
    }

    func finishRewardedAd() {
        isPresentingRewarded = false
        let action = pendingRewardCompletion
        pendingRewardCompletion = nil
        action?()
    }
}


struct AdFullscreenView: View {
    @ObservedObject var manager: AdManager
    @Environment(\.dismiss) private var dismiss

    @State private var seconds = 0
    @State private var canClose = false
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // ⬇️ Schermata volutamente vuota: ci metterai tu le creatività
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 16) {
                // Countdown / Close
                if canClose {
                    Button {
                        close()
                    } label: {
                        Text("Chiudi")
                            .font(.headline)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(.white.opacity(0.15))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel("Chiudi annuncio")
                } else {
                    Text("Puoi chiudere tra \(manager.minCloseSeconds - seconds)s")
                        .font(.footnote)
                        .padding(8)
                        .background(.white.opacity(0.15))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                        .accessibilityLabel("Puoi chiudere l'annuncio tra \(manager.minCloseSeconds - seconds) secondi")
                }

                // Placeholder contenuti (per ora nulla)
                Spacer()
                Text("Spazio annuncio")
                    .font(.title3).foregroundStyle(.white.opacity(0.6))
                Spacer()
            }
            .padding()
        }
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private func start() {
        seconds = 0
        canClose = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            seconds += 1
            if seconds >= manager.minCloseSeconds { canClose = true }
            if seconds >= manager.autoDismissSeconds { close() }
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func close() {
        stop()
        manager.finishAd()
        dismiss()
    }
}


@MainActor
struct RewardedAdFullscreenView: View {
    @ObservedObject var manager: AdManager
    @ObservedObject var daily = DailyUnlockManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // Aggiungi un callback opzionale
    let onComplete: (() -> Void)?

    @State private var seconds = 0
    @State private var timer: Timer?
    
    // Aggiungi un initializer che accetti il callback
    init(manager: AdManager, onComplete: (() -> Void)? = nil) {
        self.manager = manager
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Guarda l'annuncio per sbloccare le prenotazioni di oggi")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                Text("Annuncio \(seconds)/\(manager.rewardSeconds)s")
                    .font(.title3).bold()
                    .foregroundStyle(.white.opacity(0.9))

                Text("Spazio annuncio")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                ProgressView(value: Double(seconds),
                             total: Double(manager.rewardSeconds))
                    .padding(.horizontal, 32)
            }
        }
        .interactiveDismissDisabled(true)
        .onAppear { start() }
        .onDisappear { stop() }
    }

    private func start() {
        seconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            seconds += 1
            if seconds >= manager.rewardSeconds {
                complete()
            }
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func complete() {
        stop()
        daily.unlockForToday()
        dismiss()
        // Chiama il callback se presente
        onComplete?()
    }
}
