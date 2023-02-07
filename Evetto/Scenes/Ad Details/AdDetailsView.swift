import SwiftUI
import NukeUI

struct AdDetailsView: View {
    
    @ObservedObject var viewModel: AdDetailsViewModel
    @State var presentContactsList = false
    
    var body: some View {
        ZStack {
            ScrollView {
                content
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action: viewModel.toggleFavoriteState) {
                                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            }
                            .displayLoadingOverlay(viewModel.changingFavoriteState)
                            
                            ShareLink(
                                item: viewModel.shareURL
                            ) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .redacted(reason: viewModel.didLoadData ? [] : .placeholder)
                    .allowsHitTesting(viewModel.didLoadData)
            }
            
            if presentContactsList {
                SellerContactsView(
                    contacts: viewModel.contacts,
                    selectionCallback: { contact in
                        presentContactsList.toggle()
                        viewModel.contactSeller(contact)
                    },
                    closeCallback: {
                        presentContactsList.toggle()
                    }
                )
                .animation(.easeInOut, value: UUID())
                .transition(.opacity)
            }
        }
    }
    
    private var content: some View {
        VStack {
            images
            
            titleAndPrice
            
            Divider()
            
            categoryAndDate
            
            if let text = viewModel.descriptionText {
                descriptionText(text)
            }
            
            Button("Связаться") {
                withAnimation {
                    presentContactsList.toggle()
                }
            }
            .buttonStyle(.primaryAction)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
    
    private var imagePlaceholder: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.secondary)
            .font(Font.title.weight(.light))
            .padding(20)
            .unredacted()
    }
    
    private var images: some View {
        TabView {
            if viewModel.didLoadData, !viewModel.imageURLs.isEmpty {
                ForEach(viewModel.imageURLs, id: \.self) { url in
                    LazyImage(
                        url: url,
                        content: { state in
                            if let error = state.error {
                                Color.red
                                    .overlay(
                                        Text(error.localizedDescription)
                                    )
                            } else if let image = state.image {
                                image
                            } else {
                                imagePlaceholder
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                    )
                            }
                        }
                    )
                }
            } else {
                imagePlaceholder
            }
        }
        .tabViewStyle(.page)
        .frame(height: 250)
        .frame(maxWidth: .infinity)
    }
    
    private var titleAndPrice: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(viewModel.title)
                    .font(.title2)
                
                if let location = viewModel.location {
                    Text(location)
                        .foregroundColor(Color.secondary)
                }
            }
            
            Spacer()
            
            Text(viewModel.price)
                .foregroundColor(Color.white)
                .padding(6)
                .background(Color.accentColor)
                .clipShape(Capsule())
        }
        .padding()
    }
    
    private var categoryAndDate: some View {
        HStack {
            Text(viewModel.category)
                .font(.subheadline)
                .foregroundColor(Color.accentColor)
            Spacer()
            Text(viewModel.date)
                .font(.footnote)
                .foregroundColor(Color.secondary)
        }
        .padding()
    }
    
    private func descriptionText(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
    }
    
}

struct AdDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdDetailsView(
                viewModel: .placeholder
            )
        }
    }
}
