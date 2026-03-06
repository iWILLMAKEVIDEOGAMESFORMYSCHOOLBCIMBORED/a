import SwiftUI

struct CardDetailView: View {
    @ObservedObject var account: AccountModel
    @Binding var isPresented: Bool

    @State private var dragOffset = CGSize.zero
    @State private var rotX: Double = 0
    @State private var rotY: Double = 0

    var isDark: Bool { account.isDarkMode }
    var bg: Color { isDark ? .black : .white }
    var textP: Color { isDark ? .white : .black }
    var textS: Color { isDark ? Color(hex: "8e8e93") : Color(hex: "6c6c70") }
    var rowBg: Color { isDark ? Color(hex: "1c1c1e") : Color(hex: "f2f2f7") }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Nav
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(textP)
                        }
                        Spacer()
                        Text("Card")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(textP)
                        Spacer()
                        Color.clear.frame(width: 28)
                    }
                    .padding(.horizontal, 20).padding(.top, 56).padding(.bottom, 24)

                    // 3D draggable card
                    draggableCard
                        .padding(.horizontal, 16).padding(.bottom, 24)

                    // Lock / Copy
                    HStack(spacing: 12) {
                        cardActionBtn(icon: "lock", label: "Lock", fgColor: textS)
                        cardActionBtn(icon: "doc.on.doc", label: "Copy •• \(account.cardLastFour)", fgColor: textP)
                    }
                    .padding(.horizontal, 16).padding(.bottom, 28)

                    // Explore offers
                    offersRow

                    Divider().padding(.horizontal, 20).padding(.vertical, 4)

                    // Spending
                    sectionTitle("Spending")
                    menuRow("chart.bar.fill",   "Insights & activity",   "$3 in Mar")
                    menuRow("arrow.clockwise",  "Round Ups",             "Off")
                    menuRow("link",             "Linked merchants",      "")
                    menuRow("creditcard",       "Find an ATM",           "")

                    Divider().padding(.horizontal, 20).padding(.vertical, 8)

                    // Manage card
                    sectionTitle("Manage card")
                    menuRow("plus.rectangle.on.rectangle", "Add card to Apple Pay",  "")
                    menuRow("pencil.and.outline",          "Design a new card",      "")
                    menuRow("nosign",                      "Blocked businesses",     "")
                    menuRow("asterisk",                    "Change PIN",             "")
                    menuRow("questionmark.circle",         "Get card support",       "")

                    Color.clear.frame(height: 80)
                }
            }
        }
    }

    // MARK: - 3D Draggable Card
    var draggableCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: account.cardStyle.gradient,
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 210)
                .shadow(color: .black.opacity(0.5), radius: 20, x: rotY * 0.3, y: 10)

            // Eye icon
            VStack {
                HStack {
                    Spacer()
                    Circle().fill(Color.white.opacity(0.15)).frame(width: 36, height: 36)
                        .overlay(Image(systemName: "eye").font(.system(size: 16)).foregroundColor(.white))
                }
                Spacer()
            }
            .padding(16)

            VStack(alignment: .leading, spacing: 12) {
                Spacer()
                // Dot groups + last 4
                HStack(spacing: 18) {
                    dotGroup(4); dotGroup(4); dotGroup(4)
                    Text(account.cardLastFour)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(account.cardStyle.textColor)
                }
                // Name / CVV / EXP / VISA
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(account.cardholderName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(account.cardStyle.textColor)
                        HStack(spacing: 14) {
                            Text("CVV •••").font(.system(size: 12)).foregroundColor(account.cardStyle.textColor.opacity(0.7))
                            Text("EXP ••/••").font(.system(size: 12)).foregroundColor(account.cardStyle.textColor.opacity(0.7))
                        }
                    }
                    Spacer()
                    Text("VISA")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .italic()
                        .foregroundColor(account.cardStyle.textColor)
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 18)
        }
        // 3D tilt effect from drag
        .rotation3DEffect(.degrees(rotX), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(rotY), axis: (x: 0, y: 1, z: 0))
        .gesture(
            DragGesture()
                .onChanged { val in
                    withAnimation(.interactiveSpring()) {
                        rotY = Double(val.translation.width / 8).clamped(to: -25...25)
                        rotX = Double(-val.translation.height / 12).clamped(to: -20...20)
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        rotX = 0; rotY = 0
                    }
                }
        )
        .animation(.interactiveSpring(), value: rotX)
        .animation(.interactiveSpring(), value: rotY)
    }

    func dotGroup(_ n: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<n, id: \.self) { _ in
                Circle().fill(account.cardStyle.textColor).frame(width: 7, height: 7)
            }
        }
    }

    // MARK: - Helpers
    func cardActionBtn(icon: String, label: String, fgColor: Color) -> some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 15))
                Text(label).font(.system(size: 15, weight: .medium))
            }
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(rowBg).cornerRadius(50)
        }
    }

    var offersRow: some View {
        HStack(spacing: 14) {
            HStack(spacing: -10) {
                Circle().fill(Color.yellow).frame(width: 40, height: 40)
                    .overlay(Text("DC").font(.system(size: 11, weight: .black)).foregroundColor(.black))
                Circle().fill(Color(hex: "FF385C")).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "house.fill").font(.system(size: 16)).foregroundColor(.white))
                Circle().fill(.black).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "applelogo").font(.system(size: 16)).foregroundColor(.white))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Explore offers").font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
                Text("Instant discounts").font(.system(size: 13)).foregroundColor(textS)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(textS)
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }

    func sectionTitle(_ t: String) -> some View {
        HStack {
            Text(t).font(.system(size: 24, weight: .bold)).foregroundColor(textP)
            Spacer()
        }
        .padding(.horizontal, 20).padding(.top, 10).padding(.bottom, 6)
    }

    func menuRow(_ icon: String, _ label: String, _ detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(textP).frame(width: 28)
            Text(label).font(.system(size: 17, weight: .medium)).foregroundColor(textP)
            Spacer()
            if !detail.isEmpty { Text(detail).font(.system(size: 15)).foregroundColor(textS) }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(textS)
        }
        .padding(.horizontal, 20).padding(.vertical, 18).contentShape(Rectangle())
    }
}
}
