package com.bloodbank.util;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.cloud.FirestoreClient;
import com.google.cloud.firestore.Firestore;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

public class FirebaseConfig {

    private static Firestore firestore;

    static {
        try {
            // Path to your service account key file
            String serviceAccountPath = "lifeflow-30d1a-firebase-adminsdk-fbsvc-387a43696d.json";
            File keyFile = new File(serviceAccountPath);

            // Fallback to absolute path if running from a different directory (e.g. tomcat plugin)
            if (!keyFile.exists()) {
                keyFile = new File("c:\\\\Users\\\\user\\\\OneDrive\\\\Desktop\\\\bloodbank\\\\New folder (3)\\\\backend\\\\lifeflow-30d1a-firebase-adminsdk-fbsvc-387a43696d.json");
            }

            FileInputStream serviceAccount = new FileInputStream(keyFile);

            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .build();

            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }

            firestore = FirestoreClient.getFirestore();
            System.out.println("Firebase Firestore initialized successfully.");

        } catch (IOException e) {
            System.err.println("Firebase initialization error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public static Firestore getFirestore() {
        return firestore;
    }
}
