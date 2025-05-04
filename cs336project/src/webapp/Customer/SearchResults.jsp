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
    String departDate = request.getParameter("departDate");
    String returnDate = request.getParameter("returnDate");
    %>
    
    <div class="search-params">
        <h2>Search Parameters</h2>
        <p><strong>From:</strong> <%= origin %> 
           <strong>To:</strong> <%= destination %>
           <strong>Trip Type:</strong> <%= tripType %></p>
        <p><strong>Departure Date:</strong> <%= departDate %>
           <% if (returnDate != null && !returnDate.isEmpty()) { %>
               <strong>Return Date:</strong> <%= returnDate %>
           <% } %>
        </p>
    </div>

    <h2>Available Flights</h2>
    
    <%
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();    
    
    try {
        // Build the base query with date filtering
        String query = "SELECT f.*, a.AirlineID FROM flights f " +
                      "JOIN airlines a ON f.AirlineID = a.AirlineID " +
                      "WHERE f.DepartureAirport = ? " +
                      "AND f.ArrivalAirport = ? " +
                      "AND f.TripType = ? " +
                      "AND f.FlightDate = ?";
        
        PreparedStatement pstmt = con.prepareStatement(query);
        pstmt.setString(1, origin);
        pstmt.setString(2, destination);
        pstmt.setString(3, tripType);
        pstmt.setString(4, departDate);
        
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
                    <th>Date</th>
                    <th>Departure</th>
                    <th>Arrival</th>
                    <th>Time</th>
                    <th>Type</th>
                    <th>Economy</th>
                    <th>Business</th>
                </tr>
                <%
                while (result.next()) {
                    // Format the date for display
                    String flightDate = result.getDate("FlightDate").toString();
                %>
                <tr>
                    <td><input type="radio" name="flightSelection" value="<%= result.getInt("FlightID") %>"></td>
                    <td><%= result.getString("AirlineID") %></td>
                    <td><%= result.getString("FlightNumber") %></td>
                    <td><%= flightDate %></td>
                    <td><%= result.getString("DepartureAirport") %></td>
                    <td><%= result.getString("ArrivalAirport") %></td>
                    <td><%= result.getString("DepartureTime") %> - <%= result.getString("ArrivalTime") %></td>
                    <td><%= result.getString("FlightType") %></td>
                    <td>$<%= String.format("%.2f", result.getDouble("EconomyPrice")) %></td>
                    <td>$<%= String.format("%.2f", result.getDouble("BusinessPrice")) %></td>
                </tr>
                <%
                }
                %>
            </table>
            
            <% if ("RoundTrip".equals(tripType)) { 
                // Query for return flights if round trip
                pstmt.setString(4, returnDate);
                ResultSet returnResult = pstmt.executeQuery();
                
                if (returnResult.next()) {
            %>
                    <h3>Return Flights</h3>
                    <table>
                        <tr>
                            <th>Select</th>
                            <th>Airline</th>
                            <th>Flight No.</th>
                            <th>Date</th>
                            <th>Departure</th>
                            <th>Arrival</th>
                            <th>Time</th>
                            <th>Type</th>
                            <th>Economy</th>
                            <th>Business</th>
                        </tr>
                        <%
                        do {
                            String returnFlightDate = returnResult.getDate("FlightDate").toString();
                        %>
                        <tr>
                            <td><input type="radio" name="returnFlightSelection" value="<%= returnResult.getInt("FlightID") %>"></td>
                            <td><%= returnResult.getString("AirlineID") %></td>
                            <td><%= returnResult.getString("FlightNumber") %></td>
                            <td><%= returnFlightDate %></td>
                            <td><%= returnResult.getString("DepartureAirport") %></td>
                            <td><%= returnResult.getString("ArrivalAirport") %></td>
                            <td><%= returnResult.getString("DepartureTime") %> - <%= returnResult.getString("ArrivalTime") %></td>
                            <td><%= returnResult.getString("FlightType") %></td>
                            <td>$<%= String.format("%.2f", returnResult.getDouble("EconomyPrice")) %></td>
                            <td>$<%= String.format("%.2f", returnResult.getDouble("BusinessPrice")) %></td>
                        </tr>
                        <%
                        } while (returnResult.next());
                        %>
                    </table>
            <%
                }
                returnResult.close();
            } 
            %>
            
            <form action="Booking.jsp" method="post">
                <input type="hidden" name="tripType" value="<%= tripType %>">
                <input type="hidden" name="departDate" value="<%= departDate %>">
                <% if (returnDate != null && !returnDate.isEmpty()) { %>
                    <input type="hidden" name="returnDate" value="<%= returnDate %>">
                <% } %>
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