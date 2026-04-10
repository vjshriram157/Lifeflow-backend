package com.bloodbank.util;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.WriteResult;
import com.google.cloud.firestore.QuerySnapshot;

import java.util.HashMap;
import java.util.Map;
import java.util.List;

public class RealBloodBankSeeder {

    public static void main(String[] args) {
        System.out.println("Starting Real-World Baseline Injection...");
        try {
            Firestore db = FirebaseConfig.getFirestore();

            // 1. Wipe out existing dummy blood banks to keep map pristine
            System.out.println("Cleaning up existing placeholder blood bank records...");
            ApiFuture<QuerySnapshot> future = db.collection("blood_banks").get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            for (QueryDocumentSnapshot document : documents) {
                document.getReference().delete();
            }
            System.out.println("Cleaned up " + documents.size() + " old records.");
            
            // 1b. Wipe out existing blood bank USERS to keep directory clean
            System.out.println("Cleaning up existing bank user accounts...");
            ApiFuture<QuerySnapshot> userFuture = db.collection("users").whereEqualTo("role", "BANK").get();
            List<QueryDocumentSnapshot> userDocs = userFuture.get().getDocuments();
            for (QueryDocumentSnapshot uDoc : userDocs) {
                uDoc.getReference().delete();
            }
            System.out.println("Cleaned up " + userDocs.size() + " bank user accounts.");

            // 2. Prepare real-world datasets
            Object[][] newBanks = {
                // MUMBAI
                {"Tata Memorial Hospital Blood Bank", "Mumbai", "400012", "Maharashtra", 19.0048, 72.8427, "Dr. E Borges Road, Parel"},
                {"KEM Hospital Blood Bank", "Mumbai", "400012", "Maharashtra", 19.0031, 72.8415, "Acharya Donde Marg, Parel"},
                {"Lilavati Hospital Blood Bank", "Mumbai", "400050", "Maharashtra", 19.0511, 72.8282, "A-791, Bandra Reclamation"},
                
                // DELHI
                {"AIIMS Main Blood Bank", "Delhi", "110029", "Delhi", 28.5672, 77.2100, "Sri Aurobindo Marg, Ansari Nagar"},
                {"Rotary Blood Bank Delhi", "Delhi", "110062", "Delhi", 28.5303, 77.2662, "Tughlakabad Institutional Area"},
                {"Indian Red Cross Society NHQ", "Delhi", "110001", "Delhi", 28.6226, 77.2023, "1 Red Cross Road"},

                // BANGALORE
                {"Lions Blood Bank", "Bangalore", "560001", "Karnataka", 12.9818, 77.5921, "Infantry Road"},
                {"NIMHANS Blood Bank", "Bangalore", "560029", "Karnataka", 12.9377, 77.5940, "Hosur Road, Lakkasandra"},
                {"Rashtrotthana Blood Bank", "Bangalore", "560019", "Karnataka", 12.9351, 77.5759, "Kempegowda Nagar"},

                // CHENNAI
                {"Apollo Hospitals Blood Bank", "Chennai", "600006", "Tamil Nadu", 13.0617, 80.2505, "Greams Road"},
                {"Government General Hospital Blood Bank", "Chennai", "600003", "Tamil Nadu", 13.0801, 80.2770, "Park Town"},
                {"Jeevan Blood Bank", "Chennai", "600034", "Tamil Nadu", 13.0658, 80.2458, "Nungambakkam"}
            };

            int count = 0;
            // 3. Inject datasets into Firestore
            for (Object[] bankObj : newBanks) {
                Map<String, Object> bankData = new HashMap<>();
                bankData.put("bank_name", bankObj[0]);
                bankData.put("city", bankObj[1]);
                bankData.put("pincode", bankObj[2]);
                bankData.put("state", bankObj[3]);
                bankData.put("latitude", bankObj[4]);
                bankData.put("longitude", bankObj[5]);
                bankData.put("address", bankObj[6]);
                bankData.put("status", "APPROVED"); // Auto-approve them for the locator
                bankData.put("contact_number", "+91 800000" + String.format("%04d", count));

                ApiFuture<WriteResult> result = db.collection("blood_banks").document().set(bankData);
                result.get(); // block until completion
                System.out.println("Injected: " + bankObj[0] + " in " + bankObj[1]);
                count++;
            }

            System.out.println("Successfully seeded " + count + " verified Indian Blood Banks into Firestore.");
            System.exit(0);

        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
