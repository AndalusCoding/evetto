import SwiftUI
import NukeUI

struct AdDetailsView: View {
    
    @ObservedObject var viewModel: AdDetailsViewModel
    
    var body: some View {
        ScrollView {
            content
                .redacted(reason: viewModel.didLoadData ? [] : .placeholder)
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
            
            Button("Связаться", action: {})
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
                .background(Color.blue)
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
        AdDetailsView(
            viewModel: .placeholder
        )
    }
}
