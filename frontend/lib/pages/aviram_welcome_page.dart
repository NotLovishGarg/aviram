import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class AviramWelcomePage extends StatefulWidget {
  @override
  _AviramWelcomePageState createState() => _AviramWelcomePageState();
}

class _AviramWelcomePageState extends State<AviramWelcomePage> {
  GoogleMapController? mapController;
  LatLng? _currentLocation;
  bool _isNavigating = false;
  String? _selectedCity;
  String? _selectedHospital;
  final Map<String, List<String>> hospitals = {
    'Patiala': ['Manipal Hospital', 'Amar Hospital', 'Rajendra Hospital'],
    'Ludhiana': ['DMC', 'Apollo Hospital', 'Fortis Hospital'],
    'Chandigarh': ['PGI', 'GMC', 'Fortis Hospital'],
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _startNavigation() {
    if (_selectedHospital != null) {
      setState(() {
        _isNavigating = true;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        _navigateToSelectedHospital();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select a hospital before navigating.')));
    }
  }

  void _navigateToSelectedHospital() async {
    if (_selectedHospital != null && _currentLocation != null) {
      String fullHospitalName = '$_selectedHospital, $_selectedCity';

      final String encodedHospital = Uri.encodeComponent(fullHospitalName);
      final String googleMapsUrl =
          "https://www.google.com/maps/dir/?api=1&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=$encodedHospital&travelmode=driving";

      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    }
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButton<String>(
          value: _selectedCity,
          hint: Text('Select City'),
          items: hospitals.keys.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCity = newValue;
              _selectedHospital = null;
            });
          },
        ),
        if (_selectedCity != null)
          DropdownButton<String>(
            value: _selectedHospital,
            hint: Text('Select Hospital'),
            items: hospitals[_selectedCity]!.map((String hospital) {
              return DropdownMenuItem<String>(
                value: hospital,
                child: Text(hospital),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedHospital = newValue;
              });
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset("assets/logo.png", height: 40),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  height: _isNavigating
                      ? MediaQuery.of(context).size.height * 0.8
                      : MediaQuery.of(context).size.height * 0.3,
                  child: _currentLocation == null
                      ? Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLocation!,
                            zoom: 15.0,
                          ),
                          myLocationEnabled: true,
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                        ),
                ),
                if (!_isNavigating) ...[
                  SizedBox(height: 10),
                  _buildDropdowns(),
                  _buildInfoCard(
                    icon: Icons.person,
                    title: "User Information",
                    subtitle:
                        "Name: Abcd\nPhone: 123-456-7890\nHospital ID: H-123\nHospital: ${_selectedHospital ?? 'Not selected'}",
                  ),
                  _buildInfoCard(
                    icon: Icons.local_hospital,
                    title: "Ambulance Information",
                    subtitle: "Ambulance Number: 456\nAmbulance ID: A-789",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _startNavigation,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color.fromARGB(255, 144, 223, 79),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Navigate",
                      style: GoogleFonts.anekLatin(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
