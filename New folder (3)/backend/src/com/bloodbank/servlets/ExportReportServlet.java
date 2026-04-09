package com.bloodbank.servlets;

import com.bloodbank.util.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/ExportReportServlet")
public class ExportReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equalsIgnoreCase((String) session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"System_Report.csv\"");

        try (PrintWriter out = response.getWriter()) {
             
            out.println("ID,Full Name,Role,Email,Phone,Blood Group,Status,City");

            Firestore db = FirebaseConfig.getFirestore();
            QuerySnapshot usersSnapshot = db.collection("users").get().get();
            List<QueryDocumentSnapshot> users = usersSnapshot.getDocuments();

            for (QueryDocumentSnapshot user : users) {
                out.print(escapeCSV(user.getId()) + ",");
                out.print(escapeCSV(user.getString("full_name")) + ",");
                out.print(escapeCSV(user.getString("role")) + ",");
                out.print(escapeCSV(user.getString("email")) + ",");
                out.print(escapeCSV(user.getString("phone")) + ",");
                out.print(escapeCSV(user.getString("blood_group")) + ",");
                out.print(escapeCSV(user.getString("status")) + ",");
                out.print(escapeCSV(user.getString("city")) + "\n");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating report");
        }
    }

    private String escapeCSV(String data) {
        if (data == null) return "";
        data = data.replaceAll("\"", "\"\"");
        if (data.contains(",") || data.contains("\"") || data.contains("\n")) {
            return "\"" + data + "\"";
        }
        return data;
    }
}
