<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Flight Booking</title>
</head>
<body>
    <%
    String username = (String) session.getAttribute("user");
    if (username == null) {
        response.sendRedirect("../displayLogin.jsp");
        return;
    }
    
    String flightID = request.getParameter("flightSelection");
    String returnFlightID = request.getParameter("returnFlightSelection");
    String tripType = request.getParameter("tripType");
    String departDate = request.getParameter("departDate");
    String returnDate = request.getParameter("returnDate");
    String seatClass = request.getParameter("seatClass");
    
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();
    
    try {

        String checkFlightQuery = "SELECT * FROM flights WHERE FlightID = ?";
        PreparedStatement checkFlightStmt = con.prepareStatement(checkFlightQuery);
        checkFlightStmt.setInt(1, Integer.parseInt(flightID));
        ResultSet flightResult = checkFlightStmt.executeQuery();
        
        if (!flightResult.next()) {
    %>
            <p class="error">The selected flight is no longer available.</p>
    <%
        } else {
            // Check seat availability
            int availableSeats = 0;
            String seatColumn = "";
            
            if (seatClass == null || seatClass.equals("Economy")) {
                seatColumn = "EconomySeats";
            } else if (seatClass.equals("Business")) {
                seatColumn = "BusinessSeats";
            } else if (seatClass.equals("First")) {
                seatColumn = "FirstSeats";
            }
            
            availableSeats = flightResult.getInt(seatColumn);
            
            if (availableSeats <= 0) {
    %>
                <p class="error">Sorry, there are no more <%= seatClass %> seats available on this flight.</p>
    <%
            } else {
                // Book the flight
                String bookFlightQuery = "INSERT INTO tickets (Username, FlightID, SeatClass, BookingDate) VALUES (?, ?, ?, NOW())";
                PreparedStatement bookFlightStmt = con.prepareStatement(bookFlightQuery);
                bookFlightStmt.setString(1, username);
                bookFlightStmt.setInt(2, Integer.parseInt(flightID));
                bookFlightStmt.setString(3, seatClass);
                int rowsAffected = bookFlightStmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    // Update available seats
                    String updateSeatsQuery = "UPDATE flights SET " + seatColumn + " = " + seatColumn + " - 1 WHERE FlightID = ?";
                    PreparedStatement updateSeatsStmt = con.prepareStatement(updateSeatsQuery);
                    updateSeatsStmt.setInt(1, Integer.parseInt(flightID));
                    updateSeatsStmt.executeUpdate();
    %>
                    <h2 class="success">Booking Confirmed!</h2>
                    <h3>Outbound Flight Details</h3>
                    <table>
                        <tr>
                            <th>Airline</th>
                            <th>Flight Number</th>
                            <th>Departure</th>
                            <th>Arrival</th>
                            <th>Date</th>
                            <th>Class</th>
                        </tr>
                        <tr>
                            <td><%= flightResult.getString("AirlineID") %></td>
                            <td><%= flightResult.getString("FlightNumber") %></td>
                            <td><%= flightResult.getString("DepartureAirport") %> at <%= flightResult.getString("DepartureTime") %></td>
                            <td><%= flightResult.getString("ArrivalAirport") %> at <%= flightResult.getString("ArrivalTime") %></td>
                            <td><%= departDate %></td>
                            <td><%= seatClass %></td>
                        </tr>
                    </table>
    <%
                    // Handle return flight if round trip
                    if ("RoundTrip".equals(tripType) && returnFlightID != null && !returnFlightID.isEmpty()) {
                        checkFlightStmt.setInt(1, Integer.parseInt(returnFlightID));
                        ResultSet returnFlightResult = checkFlightStmt.executeQuery();
                        
                        if (returnFlightResult.next()) {
                            // Check return flight seat availability
                            int returnAvailableSeats = returnFlightResult.getInt(seatColumn);
                            
                            if (returnAvailableSeats <= 0) {
    %>
                                <p class="error">Sorry, there are no more <%= seatClass %> seats available on your return flight.</p>
    <%
                            } else {
                                // Book the return flight
                                bookFlightStmt.setInt(2, Integer.parseInt(returnFlightID));
                                rowsAffected = bookFlightStmt.executeUpdate();
                                
                                if (rowsAffected > 0) {
                                    // Update return flight seats
                                    updateSeatsStmt.setInt(1, Integer.parseInt(returnFlightID));
                                    updateSeatsStmt.executeUpdate();
    %>
                                    <h3>Return Flight Details</h3>
                                    <table>
                                        <tr>
                                            <th>Airline</th>
                                            <th>Flight Number</th>
                                            <th>Departure</th>
                                            <th>Arrival</th>
                                            <th>Date</th>
                                            <th>Class</th>
                                        </tr>
                                        <tr>
                                            <td><%= returnFlightResult.getString("AirlineID") %></td>
                                            <td><%= returnFlightResult.getString("FlightNumber") %></td>
                                            <td><%= returnFlightResult.getString("DepartureAirport") %> at <%= returnFlightResult.getString("DepartureTime") %></td>
                                            <td><%= returnFlightResult.getString("ArrivalAirport") %> at <%= returnFlightResult.getString("ArrivalTime") %></td>
                                            <td><%= returnDate %></td>
                                            <td><%= seatClass %></td>
                                        </tr>
                                    </table>
    <%
                                }
                            }
                        }
                        returnFlightResult.close();
                    }
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
        <p class="error">An error occurred while processing your booking. Please try again.</p>
    <%
    } finally {
        if (con != null) con.close();
    }
    %>
    
    <br/>
    <a href="CustomerDash.jsp">Back to Dashboard</a>
</body>
</html>