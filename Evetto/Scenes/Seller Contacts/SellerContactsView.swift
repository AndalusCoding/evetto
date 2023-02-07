import SwiftUI

struct SellerContactsView: View {
    
    let contacts: [Contact]
    let selectionCallback: (Contact) -> Void
    let closeCallback: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea(edges: .all)
            
            VStack(spacing: 0) {
                contactsList
                
                Divider()
                
                Button("Закрыть", action: closeCallback)
                    .padding(.vertical, 16)
                    .bold()
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.vertical)
            .padding(.horizontal, 40)
        }
    }
    
    private var contactsList: some View {
        VStack(spacing: 8) {
            ForEach(contacts) { contact in
                Button {
                    selectionCallback(contact)
                } label: {
                    Text(contact.formattedTitle + ": " + contact.displayValue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(contactItemBackgroundColor(contact.type))
                        .cornerRadius(10)
                        .foregroundColor(Color.white)
                        .font(Font.body.bold())
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
    }
    
    private func contactItemBackgroundColor(_ type: Contact.Kind) -> Color {
        switch type {
        case .instagram: return Color.purple
        case .phone: return Color.gray
        case .whatsapp: return Color.green
        case .telegram: return Color.blue
        }
    }
    
}

struct SellerContactsView_Previews: PreviewProvider {
    static var previews: some View {
        SellerContactsView(
            contacts: [
                .placeholderPhone,
                .placeholderTelegram,
            ],
            selectionCallback: { _ in },
            closeCallback: {}
        )
    }
}
