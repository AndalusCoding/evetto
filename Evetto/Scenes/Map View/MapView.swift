import SwiftUI
import MapKit

struct MapView: View {
    
    @ObservedObject var viewModel: MapViewModel
    var showLocateUserButton: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            map
            
            if showLocateUserButton {
                Button(action: {
                    withAnimation(.spring()) {
                        viewModel.showUsersLocation()
                    }
                }, label: {
                    Image(systemName: "scope")
                        .resizable()
                        .foregroundColor(Color.black.opacity(0.75))
                        .frame(width: 30, height: 30)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(Circle())
                        .padding()
                        .shadow(radius: 3)
                })
            }
        }
    }
    
    var map: some View {
        Map(
            coordinateRegion: $viewModel.coordinateRegion,
            interactionModes: .all,
            showsUserLocation: true,
            annotationItems: viewModel.annotations,
            annotationContent: { item in
                MapMarker(coordinate: item.coordinate)
            }
        )
        .ignoresSafeArea(.all)
        .onAppear(perform: viewModel.requestUserLocationPermission)
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            viewModel: .placeholder
        )
    }
}
