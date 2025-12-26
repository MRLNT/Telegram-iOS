import SwiftUI

struct LiquidGlassToggleStyle: ToggleStyle {
    var onColor: Color
    var offColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 51, height: 31)
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.8),
                                    .white.opacity(0.2),
                                    .clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
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
                .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                .frame(width: 27, height: 27)
                .offset(x: configuration.isOn ? 10 : -10)
            }
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

struct LiquidGlassSwitchView: View {
    @Binding var isOn: Bool
    
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
