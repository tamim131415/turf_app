import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionService {
  static Future<Map<String, dynamic>> testFirebaseConnection() async {
    final Map<String, dynamic> result = {
      'isConnected': false,
      'firebaseInitialized': false,
      'firestoreWorking': false,
      'canReadWrite': false,
      'error': null,
      'details': {},
    };

    try {
      // Step 1: Check if Firebase is initialized
      try {
        Firebase.app();
        result['firebaseInitialized'] = true;
        result['details']['firebase'] = 'Initialized successfully';
      } catch (e) {
        result['error'] = 'Firebase not initialized: $e';
        return result;
      }

      // Step 2: Test Firestore connection
      try {
        final firestore = FirebaseFirestore.instance;

        // Enable network (in case it was disabled)
        await firestore.enableNetwork();

        // Try to read from Firestore with timeout
        final testDoc = await firestore
            .collection('connection_test')
            .doc('test')
            .get()
            .timeout(Duration(seconds: 10));

        result['firestoreWorking'] = true;
        result['details']['firestore_read'] = 'Connection successful';

        // Step 3: Test write capability
        await firestore
            .collection('connection_test')
            .doc('test')
            .set({
              'timestamp': FieldValue.serverTimestamp(),
              'test_data': 'Firebase connection test',
              'app_name': 'Turf-Mate',
            })
            .timeout(Duration(seconds: 10));

        result['canReadWrite'] = true;
        result['details']['firestore_write'] = 'Write successful';
        result['isConnected'] = true;
      } catch (e) {
        result['error'] = 'Firestore error: $e';
        result['details']['firestore_error'] = e.toString();
      }
    } catch (e) {
      result['error'] = 'General Firebase error: $e';
    }

    return result;
  }

  static Future<Map<String, dynamic>> getFirebaseProjectInfo() async {
    try {
      final app = Firebase.app();
      final firestore = FirebaseFirestore.instance;

      return {
        'project_id': app.options.projectId,
        'app_id': app.options.appId,
        'api_key': (app.options.apiKey?.substring(0, 10) ?? 'N/A') + '...',
        'storage_bucket': app.options.storageBucket,
        'messaging_sender_id': app.options.messagingSenderId,
        'auth_domain': app.options.authDomain,
        'app_name': app.name,
        'firestore_settings': firestore.settings.toString(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<void> showConnectionDialog() async {
    Get.dialog(
      Dialog(
        child: Container(
          padding: EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Firebase Connection Test',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 10),

              FutureBuilder<Map<String, dynamic>>(
                future: testFirebaseConnection(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Testing Firebase connection...'),
                      ],
                    );
                  }

                  final result = snapshot.data ?? {};
                  final bool isConnected = result['isConnected'] ?? false;

                  return Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Connection Status
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isConnected ? Colors.green : Colors.red,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isConnected
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: isConnected
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isConnected
                                      ? 'Firebase Connected!'
                                      : 'Connection Failed',
                                  style: TextStyle(
                                    color: isConnected
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          // Test Results
                          _buildTestResult(
                            'Firebase Initialized',
                            result['firebaseInitialized'],
                          ),
                          _buildTestResult(
                            'Firestore Working',
                            result['firestoreWorking'],
                          ),
                          _buildTestResult(
                            'Read/Write Access',
                            result['canReadWrite'],
                          ),

                          if (result['error'] != null) ...[
                            SizedBox(height: 16),
                            Text(
                              'Error Details:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                result['error'].toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],

                          SizedBox(height: 16),

                          // Project Info
                          FutureBuilder<Map<String, dynamic>>(
                            future: getFirebaseProjectInfo(),
                            builder: (context, projectSnapshot) {
                              if (projectSnapshot.hasData) {
                                final projectInfo = projectSnapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Project Information:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...projectInfo.entries
                                        .map(
                                          (entry) => Padding(
                                            padding: EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  child: Text(
                                                    '${entry.key}:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    entry.value.toString(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                );
                              }
                              return SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      showConnectionDialog(); // Refresh
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Test Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                    label: Text('Close'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Widget _buildTestResult(String label, bool? status) {
    Color color = status == true ? Colors.green : Colors.red;
    IconData icon = status == true ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
