<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Flight Search Results</title>
</head>
<body>
    <%
    String origin = request.getParameter("OriAirport");
    String destination = request.getParameter("DestAirport");
    String tripType = request.getParameter("tripType");
    %>
    
    <div class="search-params">
        <h2>Search Parameters</h2>
        <p><strong>From:</strong> <%= origin %> 
           <strong>To:</strong> <%= destination %>
           <strong>Trip Type:</strong> <%= tripType %></p>
    </div>

    <h2>Available Flights</h2>
    
    <%
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();    
    
    try {
        // Build the base query
        String query = "SELECT f.*, a.AirlineID FROM flights f " +
                      "JOIN airlines a ON f.AirlineID = a.AirlineID " +
                      "WHERE f.DepartureAirport = ? " +
                      "AND f.ArrivalAirport = ? " +
                      "AND f.TripType = ?";
        
        PreparedStatement pstmt = con.prepareStatement(query);
        pstmt.setString(1, origin);
        pstmt.setString(2, destination);
        pstmt.setString(3, tripType);
        
        ResultSet result = pstmt.executeQuery();
        
        if (!result.isBeforeFirst()) {
    %>
            <p>No flights found matching your criteria.</p>
    <%
        } else {
    %>
            <table>
                <tr>
                    <th>Select</th>
                    <th>Airline</th>
                    <th>Flight No.</th>
                    <th>Departure</th>
                    <th>Arrival</th>
                    <th>Time</th>
                    <th>Duration</th>
                    <th>Type</th>
                    <th>Economy Price</th>
                    <th>Business Price</th>
                </tr>
                <%
                while (result.next()) {
                %>
                <tr>
                    <td><input type="radio" name="flightSelection" value="<%= result.getInt("FlightID") %>"></td>
                    <td><%= result.getString("AirlineID") %></td>
                    <td><%= result.getString("FlightNumber") %></td>
                    <td><%= result.getString("DepartureAirport") %></td>
                    <td><%= result.getString("ArrivalAirport") %></td>
                    <td><%= result.getString("DepartureTime") %> - <%= result.getString("ArrivalTime") %></td>
                    <td>Calculate</td>
                    <td><%= result.getString("FlightType") %></td>
                    <td>$<%= String.format("%.2f", result.getDouble("EconomyPrice")) %></td>
                    <td>$<%= String.format("%.2f", result.getDouble("BusinessPrice")) %></td>
                </tr>
                <%
                }
                %>
            </table>
            
            <% if ("RoundTrip".equals(tripType)) { %>
                <h3>Return Flights</h3>
                <!-- Similar table for return flights -->
            <% } %>
            
            <form action="Booking.jsp" method="post">
                <input type="hidden" name="tripType" value="<%= tripType %>">
                <input type="submit" value="Continue to Booking">
            </form>
    <%
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
        <p>Error retrieving flight data. Please try again later.</p>
    <%
    } finally {
        if (con != null) con.close();
    }
    %>
    
    <br/>
    <a href="CustomerDash.jsp">Modify Search</a>
</body>
</html>