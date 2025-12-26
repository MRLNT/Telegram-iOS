import SwiftUI

// 1. STYLE KHUSUS: LIQUID GLASS (MENGGUNAKAN GRADASI PANTULAN)
struct LiquidGlassToggleStyle: ToggleStyle {
    var onColor: Color
    var offColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            ZStack {
                // A. Background Capsule (Jalur Switch)
                Capsule()
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 51, height: 31)
                
                // B. Knob Kaca (Lingkaran)
                ZStack {
                    // Layer 1: Base Fill (Sedikit putih transparan)
                    Circle()
                        .fill(Color.white.opacity(0.1))
                    
                    // Layer 2: Pantulan Cahaya (Gradient Kaca)
                    // FIX: Mengganti .foregroundStyle (iOS 15) menjadi .fill (iOS 13)
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.8), // Pantulan terang di kiri atas
                                    .white.opacity(0.2),
                                    .clear               // Bening di kanan bawah
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Layer 3: Border Halus (Rim Light)
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.9),
                                    .white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                // Efek Shadow agar knob terlihat melayang
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                .frame(width: 27, height: 27)
                .offset(x: configuration.isOn ? 10 : -10)
            }
            // FIX: Animasi diletakkan di container ZStack untuk iOS 13 Support
            // (iOS 13 tidak mendukung .animation(value:))
            .animation(
                .spring(response: 0.4, dampingFraction: 0.6)
            )
            .onTapGesture {
                configuration.isOn.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
    }
}

// 2. VIEW UTAMA (BRIDGE KE TELEGRAM)
struct LiquidGlassSwitchView: View {
    @Binding var isOn: Bool
    
    // Warna yang dikirim dari Telegram (UIKit)
    var activeColor: UIColor
    var inactiveColor: UIColor
    
    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(LiquidGlassToggleStyle(
                onColor: Color(activeColor),
                offColor: Color(inactiveColor)
            ))
            .labelsHidden()
    }
}
