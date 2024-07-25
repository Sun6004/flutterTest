import 'package:budongsan/map/map_filter.dart';
import 'package:flutter/material.dart';
import 'map_filter_dialog.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budongsan/geoFire/geoflutterfire.dart';
import 'package:budongsan/geoFire/models/point.dart';
import 'apt_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  int currentItem = 0;
  MapFilter mapFilter = MapFilter();
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  MarkerId? selectedMarker;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  late List<DocumentSnapshot> documentList =
      List<DocumentSnapshot>.empty(growable: true);

  static const CameraPosition _googleMapCamera =
      CameraPosition(target: LatLng(37.571320, 127.029403), zoom: 15);

  @override
  void initState() {
    super.initState();
    addCustomIcon();
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "lib/res/images/apartment.png")
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    ).catchError((error) {
      print("Custom icon loading failed, using default marker: $error");
      setState(() {
        markerIcon = BitmapDescriptor.defaultMarker;
      });
    });
  }

  Future<void> _searchApt() async {
    print("_searchApt 함수 호출됨");
    final GoogleMapController controller = await _controller.future;
    print("GoogleMapController 획득");
    final bounds = await controller.getVisibleRegion();
    LatLng centerBounds = LatLng(
      (bounds.southwest.latitude + bounds.northeast.latitude) / 2,
      (bounds.southwest.longitude + bounds.northeast.longitude) / 2,
    );
    print("Firestore 쿼리 시작");
    final aptRef = FirebaseFirestore.instance.collection('cities');
    print(aptRef);
    final geo = Geoflutterfire();
    GeoFirePoint center = geo.point(
        latitude: centerBounds.latitude, longitude: centerBounds.longitude);

    double radius = 1;
    String field = 'position';

    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: aptRef)
        .within(center: center, radius: radius, field: field);

    stream.listen((List<DocumentSnapshot> documentList) {
      print("스트림 데이터 수신: ${documentList.length} 문서");
      this.documentList = documentList;
      drawMarker(documentList);
    }, onError: (error) {
      print("스트림 에러 발생: $error");
    }, onDone: () {
      print("스트림 완료");
    });
  }

  void drawMarker(List<DocumentSnapshot> documentList) async {
    print("drawMarker 함수 시작: ${documentList.length} 문서");

    if (markers.isNotEmpty) {
      print("기존 마커 제거 시작");
      List<MarkerId> markerIds = List.of(markers.keys);
      for (var markerId in markerIds) {
        setState(() {
          markers.remove(markerId);
        });
      }
      print("기존 마커 제거 완료");
    }

    final GoogleMapController controller = await _controller.future;
    final bounds = await controller.getVisibleRegion();

    // 영역을 약간 확장
    double latDelta =
        (bounds.northeast.latitude - bounds.southwest.latitude) * 0.1;
    double lngDelta =
        (bounds.northeast.longitude - bounds.southwest.longitude) * 0.1;

    LatLng extendedSouthwest = LatLng(bounds.southwest.latitude - latDelta,
        bounds.southwest.longitude - lngDelta);
    LatLng extendedNortheast = LatLng(bounds.northeast.latitude + latDelta,
        bounds.northeast.longitude + lngDelta);

    print("확장된 지도 영역: $extendedSouthwest, $extendedNortheast");

    for (var element in documentList) {
      var info = element.data()! as Map<String, dynamic>;
      LatLng position = LatLng(
        (info['position']['geopoint'] as GeoPoint).latitude,
        (info['position']['geopoint'] as GeoPoint).longitude,
      );
      print("문서 처리 중: ${info['name']} at $position");
      print("필터 조건 체크 시작");

      if (selectedCheck(
          info, mapFilter.peopleStr, mapFilter.carStr, mapFilter.buildingStr)) {
        print("필터 조건 통과");

        if (position.latitude >= extendedSouthwest.latitude &&
            position.latitude <= extendedNortheast.latitude &&
            position.longitude >= extendedSouthwest.longitude &&
            position.longitude <= extendedNortheast.longitude) {
          print("${info['name']} is within the extended view bounds");

          MarkerId markerId = MarkerId(info['position']['geohash']);
          Marker marker = Marker(
            markerId: markerId,
            infoWindow: InfoWindow(
                title: info['name'],
                snippet: '${info['address']}',
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AptPage(
                        aptHash: info['position']['geohash'], aptInfo: info);
                  }));
                }),
            position: position,
            icon: markerIcon,
            alpha: 1.0,
          );
          print("마커 생성: ${info['name']} at ${marker.position}");
          setState(() {
            markers[markerId] = marker;
          });
        } else {
          print("${info['name']} is outside the extended view bounds");
        }
      } else {
        print("필터 조건 미통과: ${info['name']}");
      }
    }

    print("마커 그리기 완료. 총 마커 수: ${markers.length}");
  }

  bool selectedCheck(Map<String, dynamic> info, String? peopleStr,
      String? carStr, String? buildingStr) {
    final dong = info['ALL_DONG_CO'];
    final people = info['ALL_HSHLD_CO'];
    final parking = info['CNT_PA'];

    print("Checking: ${info['name']}");
    print("dong: $dong, buildingStr: $buildingStr");
    print("people: $people, peopleStr: $peopleStr");
    print("parking: $parking, carStr: $carStr");

    // 필터링 조건 적용
    if (dong >= int.parse(buildingStr!)) {
      print("Building check passed");
      if (people >= int.parse(peopleStr!)) {
        print("People check passed");
        if (carStr == '1') {
          if (parking >= 1) {
            // 1 이상일 때 통과
            print("Parking check passed (1 or more)");
            return true;
          } else {
            print("Parking check failed (less than 1)");
            return false;
          }
        } else {
          if (parking < 1) {
            // 1 미만일 때 통과
            print("Parking check passed (less than 1)");
            return true;
          } else {
            print("Parking check failed (1 or more)");
            return false;
          }
        }
      } else {
        print("People check failed");
        return false;
      }
    } else {
      print("Building check failed");
      return false;
    }
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
              icon: const Icon(Icons.search))
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
          : ListView.builder(
              itemBuilder: (context, value) {
                Map<String, dynamic> item =
                    documentList[value].data() as Map<String, dynamic>;
                return InkWell(
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.apartment),
                      title: Text(item['name']),
                      subtitle: Text(item['address']),
                      trailing: const Icon(Icons.arrow_circle_right_sharp),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return AptPage(
                          aptHash: item['position']['geohash'], aptInfo: item);
                    }));
                  },
                );
              },
              itemCount: documentList.length,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentItem,
        onTap: (value) {
          if (value == 0) {
            _controller = Completer<GoogleMapController>();
          }
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
          onPressed: () {
            _searchApt();
          },
          label: const Text('Search here')),
    );
  }
}
