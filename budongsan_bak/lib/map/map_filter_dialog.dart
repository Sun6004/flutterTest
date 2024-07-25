import 'package:flutter/material.dart';

import 'map_filter.dart';

class MapFilterDialog extends StatefulWidget {
  final MapFilter mapFilter;
  const MapFilterDialog(this.mapFilter, {super.key});

  @override
  State<MapFilterDialog> createState() => _MapFilterDialog();
}

class _MapFilterDialog extends State<MapFilterDialog> {
  late MapFilter mapFilter;
  final List<DropdownMenuItem<String>> _buildingDownMenuItems = [
    const DropdownMenuItem<String>(
      value: '1',
      child: Text('1동'),
    ),
    const DropdownMenuItem<String>(
      value: '2',
      child: Text('2동'),
    ),
    const DropdownMenuItem<String>(
      value: '3',
      child: Text('3동이상'),
    )
  ];

  final List<DropdownMenuItem<String>> _peopleDropDownMenuItems = [
    const DropdownMenuItem<String>(
      value: '0',
      child: Text('all'),
    ),
    const DropdownMenuItem<String>(
      value: '100',
      child: Text('100세대 이상'),
    ),
    const DropdownMenuItem<String>(
      value: '300',
      child: Text('300세대 이상'),
    ),
    const DropdownMenuItem<String>(
      value: '500',
      child: Text('500세대 이상'),
    ),
  ];

  final List<DropdownMenuItem<String>> _carDownMenuItems = [
    const DropdownMenuItem(value: '1', child: Text('세대별 1대 미만')),
    const DropdownMenuItem(value: '2', child: Text('세대별 1대 이상')),
  ];

  @override
  void initState() {
    super.initState();
    mapFilter = widget.mapFilter;
    mapFilter.buildingStr = _buildingDownMenuItems.first.value!;
    mapFilter.peopleStr = _peopleDropDownMenuItems.first.value!;
    mapFilter.carStr = _carDownMenuItems.first.value!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('My budongsan'),
      content: SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButton(
                items: _buildingDownMenuItems,
                onChanged: (value) {
                  setState(() {
                    mapFilter.buildingStr = value!;
                  });
                },
                value: mapFilter.buildingStr,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButton(
                items: _peopleDropDownMenuItems,
                onChanged: (value) {
                  setState(() {
                    mapFilter.peopleStr;
                  });
                },
                value: mapFilter.peopleStr,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: DropdownButton(
                items: _carDownMenuItems,
                onChanged: (value) {
                  setState(() {
                    mapFilter.carStr;
                  });
                },
                value: mapFilter.carStr,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(mapFilter);
                    },
                    child: const Text('확인')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
