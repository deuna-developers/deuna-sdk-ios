import DeunaSDK
import SwiftUI

struct WalletsScreen: View {
    let deunaSDK: DeunaSDK
    let orderToken: String?
    let userInfo: DeunaSDK.UserInfo?

    @State private var availableWallets: [WalletProvider] = []
    @State private var isFetchingWallets = false
    @State private var fetchError: String?
    @State private var successJson: String?
    @State private var errorMessage: String?
    @State private var closedMessage: String?
    @State private var copiedConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                fetchButton
                if let fetchError {
                    statusCard(message: fetchError, color: .red, icon: "exclamationmark.triangle.fill")
                }
                walletButtons
                if let successJson {
                    successCard(json: successJson)
                }
                if let errorMessage {
                    statusCard(message: errorMessage, color: .red, icon: "xmark.circle.fill")
                }
                if let closedMessage {
                    statusCard(message: closedMessage, color: .orange, icon: "xmark.circle")
                }
            }
            .padding(16)
        }
        .navigationTitle("Wallets")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var fetchButton: some View {
        Button(action: getWallets) {
            HStack(spacing: 8) {
                if isFetchingWallets {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.85)
                }
                Text(isFetchingWallets ? "Fetching..." : "Get Wallets Available")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.blue)
            .cornerRadius(24)
        }
        .disabled(isFetchingWallets)
        .opacity(isFetchingWallets ? 0.85 : 1)
    }

    @ViewBuilder
    private var walletButtons: some View {
        if !availableWallets.isEmpty {
            VStack(spacing: 10) {
                Text("Available Wallets")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(availableWallets, id: \.self) { wallet in
                    Button(action: { launchWallet(wallet) }) {
                        HStack(spacing: 10) {
                            Image(systemName: walletIcon(wallet))
                                .font(.system(size: 16, weight: .medium))
                            Text(walletLabel(wallet))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .cornerRadius(24)
                    }
                }
            }
        }
    }

    private func successCard(json: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Success")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.green)
                Spacer()
                Button(action: copyJson) {
                    HStack(spacing: 4) {
                        Image(systemName: copiedConfirmation ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12))
                        Text(copiedConfirmation ? "Copied" : "Copy")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(copiedConfirmation ? .green : .blue)
                }
            }

            ScrollView(.vertical, showsIndicators: true) {
                Text(json)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 200)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.green.opacity(0.4), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func statusCard(message: String, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.system(size: 16))
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func getWallets() {
        isFetchingWallets = true
        fetchError = nil
        availableWallets = []
        successJson = nil
        errorMessage = nil
        closedMessage = nil

        let params = GetWalletsAvailableParams(orderToken: orderToken, userInfo: userInfo)
        deunaSDK.getWalletsAvailable(params: params) { wallets, error in
            isFetchingWallets = false
            if let error {
                fetchError = "[\(error.code)] \(error.message)"
            } else {
                availableWallets = wallets
                if wallets.isEmpty {
                    fetchError = "No wallets available on this device."
                }
            }
        }
    }

    private func launchWallet(_ wallet: WalletProvider) {
        successJson = nil
        errorMessage = nil
        closedMessage = nil

        deunaSDK.initElements(
            callbacks: ElementsCallbacks(
                onSuccess: { data in
                    if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                       let pretty = String(data: jsonData, encoding: .utf8)
                    {
                        successJson = pretty
                    } else {
                        successJson = String(describing: data)
                    }
                },
                onError: { error in
                    let code = error.metadata?.code ?? "ERROR"
                    let msg = error.metadata?.message ?? error.type.message
                    errorMessage = "[\(code)] \(msg)"
                },
                onClosed: { _ in
                    if successJson == nil {
                        closedMessage = "Payment sheet closed without completing."
                    }
                },
                onEventDispatch: nil
            ),
            userInfo: userInfo,
            types: [["name": wallet.processorName.uppercased()]],
            orderToken: orderToken
        )
    }

    private func copyJson() {
        guard let successJson else { return }
        UIPasteboard.general.string = successJson
        copiedConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedConfirmation = false
        }
    }

    private func walletLabel(_ wallet: WalletProvider) -> String {
        switch wallet {
        case .applePay: return "Apple Pay"
        }
    }

    private func walletIcon(_ wallet: WalletProvider) -> String {
        switch wallet {
        case .applePay: return "apple.logo"
        }
    }
}
