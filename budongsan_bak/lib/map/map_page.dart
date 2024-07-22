import 'package:budongsan/map/map_filter.dart';
import 'package:flutter/material.dart';
import 'map_filter_dialog.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  int currentItem = 0;
  MapFilter mapFilter = MapFilter();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  static const CameraPosition _googleMapCamera =
      CameraPosition(target: LatLng(37.571320, 127.029403), zoom: 15);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My budongsan'),
        actions: [
          IconButton(
              onPressed: () async {
                var res = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MapFilterDialog(mapFilter);
                }));
                if (res != null) {
                  mapFilter = res as MapFilter;
                }
              },
              icon: Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 51, 51, 51),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'asd',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'asd@gmail.com',
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Selected Apartment'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('setting'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: currentItem == 0
          ? GoogleMap(
              initialCameraPosition: _googleMapCamera,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: Set<Marker>.of(markers.values),
            )
          : ListView(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentItem,
        onTap: (value) {
          setState(() {
            currentItem = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'map'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'list'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {}, label: const Text('Search here')),
    );
  }
}
