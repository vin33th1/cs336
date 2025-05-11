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
    String dateFlexibility = request.getParameter("dateFlexibility");
    String maxStops = request.getParameter("maxStops");
    String airlineFilter = request.getParameter("airlineFilter");
    String minPrice = request.getParameter("minPrice");
    String maxPrice = request.getParameter("maxPrice");
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    if (sortBy == null) sortBy = "DepartureTime";
    if (sortOrder == null) sortOrder = "ASC";
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
           <% if (dateFlexibility != null && !dateFlexibility.equals("0")) { %>
               <strong>Date Flexibility:</strong> +/- <%= dateFlexibility %> days
           <% } %>
        </p>
    </div>

    <h2>Available Flights</h2>
    
    <div class="sort-options">
        <form method="get" action="SearchResults.jsp">
            <input type="hidden" name="OriAirport" value="<%= origin %>">
            <input type="hidden" name="DestAirport" value="<%= destination %>">
            <input type="hidden" name="tripType" value="<%= tripType %>">
            <input type="hidden" name="departDate" value="<%= departDate %>">
            <% if (returnDate != null && !returnDate.isEmpty()) { %>
                <input type="hidden" name="returnDate" value="<%= returnDate %>">
            <% } %>
            <input type="hidden" name="dateFlexibility" value="<%= dateFlexibility %>">
            
            <label for="sortBy">Sort by:</label>
            <select name="sortBy" id="sortBy" onchange="this.form.submit()">
                <option value="DepartureTime" <%= sortBy.equals("DepartureTime") ? "selected" : "" %>>Take-off Time</option>
                <option value="ArrivalTime" <%= sortBy.equals("ArrivalTime") ? "selected" : "" %>>Landing Time</option>
                <option value="DurationMinutes" <%= sortBy.equals("DurationMinutes") ? "selected" : "" %>>Flight Duration</option>
                <option value="EconomyPrice" <%= sortBy.equals("EconomyPrice") ? "selected" : "" %>>Price (Economy)</option>
                <option value="BusinessPrice" <%= sortBy.equals("BusinessPrice") ? "selected" : "" %>>Price (Business)</option>
            </select>
            
            <select name="sortOrder" id="sortOrder" onchange="this.form.submit()">
                <option value="ASC" <%= sortOrder.equals("ASC") ? "selected" : "" %>>Ascending</option>
                <option value="DESC" <%= sortOrder.equals("DESC") ? "selected" : "" %>>Descending</option>
            </select>
        </form>
    </div>
    
    <%
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();    
    
    try {

        String query = "SELECT f.*, a.AirlineID FROM flights f " +
                      "JOIN airlines a ON f.AirlineID = a.AirlineID " +
                      "WHERE f.DepartureAirport = ? " +
                      "AND f.ArrivalAirport = ? " +
                      "AND f.TripType = ? ";
        
        // Handle date flexibility
        if (dateFlexibility == null || dateFlexibility.equals("0")) {
            query += "AND f.FlightDate = ? ";
        } else {
            int flexDays = Integer.parseInt(dateFlexibility);
            query += "AND f.FlightDate BETWEEN DATE_SUB(?, INTERVAL " + flexDays + " DAY) " +
                     "AND DATE_ADD(?, INTERVAL " + flexDays + " DAY) ";
        }
        
        // Add filters
        if (maxStops != null && !maxStops.isEmpty()) {
            query += "AND f.Stops <= " + maxStops + " ";
        }
        
        if (airlineFilter != null && !airlineFilter.isEmpty()) {
            query += "AND f.AirlineID = '" + airlineFilter + "' ";
        }
        
        if (minPrice != null && !minPrice.isEmpty()) {
            query += "AND f.EconomyPrice >= " + minPrice + " ";
        }
        
        if (maxPrice != null && !maxPrice.isEmpty()) {
            query += "AND f.EconomyPrice <= " + maxPrice + " ";
        }
        
        // Add sorting
        query += "ORDER BY " + sortBy + " " + sortOrder;
        
        PreparedStatement pstmt = con.prepareStatement(query);
        pstmt.setString(1, origin);
        pstmt.setString(2, destination);
        pstmt.setString(3, tripType);
        pstmt.setString(4, departDate);
        
        if (!(dateFlexibility == null || dateFlexibility.equals("0"))) {
            pstmt.setString(5, departDate);
        }
        
        ResultSet result = pstmt.executeQuery();
        
        if (!result.isBeforeFirst()) {
    %>
            <p>No flights found matching your criteria.</p>
    <%
        } else {
    %>
            <form action="Booking.jsp" method="post">
                <table>
                    <tr>
                        <th>Select</th>
                        <th>Airline</th>
                        <th>Flight No.</th>
                        <th>Date</th>
                        <th>
                            <a href="SearchResults.jsp?OriAirport=<%= origin %>&DestAirport=<%= destination %>&tripType=<%= tripType %>&departDate=<%= departDate %><% if (returnDate != null && !returnDate.isEmpty()) { %>&returnDate=<%= returnDate %><% } %>&dateFlexibility=<%= dateFlexibility %>&sortBy=DepartureTime&sortOrder=<%= sortBy.equals("DepartureTime") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                Take-off Time
                                <% if(sortBy.equals("DepartureTime")) { %>
                                    <span class="sort-indicator"><%= sortOrder.equals("ASC") ? "(earliest first)" : "(latest first)" %></span>
                                <% } %>
                            </a>
                        </th>
                        <th>Arrival</th>
                        <th>Flight Duration</th>
                        <th>Stops</th>
                        <th>Type</th>
                        <th>Economy</th>
                        <th>Business</th>
                        <th>First</th>
                    </tr>
                    <%
                    while (result.next()) {
                        String flightDate = result.getDate("FlightDate").toString();
                        int duration = result.getInt("DurationMinutes");
                        String durationStr = (duration / 60) + "h " + (duration % 60) + "m";
                    %>
                    <tr>
                        <td><input type="radio" name="flightSelection" value="<%= result.getInt("FlightID") %>" required></td>
                        <td><%= result.getString("AirlineID") %></td>
                        <td><%= result.getString("FlightNumber") %></td>
                        <td><%= flightDate %></td>
                        <td><%= result.getString("DepartureTime") %></td>
                        <td><%= result.getString("ArrivalTime") %></td>
                        <td><%= durationStr %></td>
                        <td><%= result.getInt("Stops") %></td>
                        <td><%= result.getString("FlightType") %></td>
                        <td>$<%= String.format("%.2f", result.getDouble("EconomyPrice")) %></td>
                        <td>$<%= String.format("%.2f", result.getDouble("BusinessPrice")) %></td>
                        <td>$<%= String.format("%.2f", result.getDouble("FirstPrice")) %></td>
                    </tr>
                    <%
                    }
                    %>
                </table>
                
                <% if ("RoundTrip".equals(tripType)) { 
                  
                    pstmt.setString(4, returnDate);
                    if (!(dateFlexibility == null || dateFlexibility.equals("0"))) {
                        pstmt.setString(5, returnDate);
                    }
                    
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
                                <th>
                                    <a href="SearchResults.jsp?OriAirport=<%= origin %>&DestAirport=<%= destination %>&tripType=<%= tripType %>&departDate=<%= departDate %><% if (returnDate != null && !returnDate.isEmpty()) { %>&returnDate=<%= returnDate %><% } %>&dateFlexibility=<%= dateFlexibility %>&sortBy=DepartureTime&sortOrder=<%= sortBy.equals("DepartureTime") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                        Take-off Time
                                        <% if(sortBy.equals("DepartureTime")) { %>
                                            <span class="sort-indicator"><%= sortOrder.equals("ASC") ? "(earliest first)" : "(latest first)" %></span>
                                        <% } %>
                                    </a>
                                </th>
                                <th>Arrival</th>
                                <th>Flight Duration</th>
                                <th>Stops</th>
                                <th>Type</th>
                                <th>Economy</th>
                                <th>Business</th>
                                <th>First</th>
                            </tr>
                            <%
                            do {
                                String returnFlightDate = returnResult.getDate("FlightDate").toString();
                                int returnDuration = returnResult.getInt("DurationMinutes");
                                String returnDurationStr = (returnDuration / 60) + "h " + (returnDuration % 60) + "m";
                            %>
                            <tr>
                                <td><input type="radio" name="returnFlightSelection" value="<%= returnResult.getInt("FlightID") %>" required></td>
                                <td><%= returnResult.getString("AirlineID") %></td>
                                <td><%= returnResult.getString("FlightNumber") %></td>
                                <td><%= returnFlightDate %></td>
                                <td><%= returnResult.getString("DepartureTime") %></td>
                                <td><%= returnResult.getString("ArrivalTime") %></td>
                                <td><%= returnDurationStr %></td>
                                <td><%= returnResult.getInt("Stops") %></td>
                                <td><%= returnResult.getString("FlightType") %></td>
                                <td>$<%= String.format("%.2f", returnResult.getDouble("EconomyPrice")) %></td>
                                <td>$<%= String.format("%.2f", returnResult.getDouble("BusinessPrice")) %></td>
                                <td>$<%= String.format("%.2f", returnResult.getDouble("FirstPrice")) %></td>
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
 
                <div class="seat-selection">
                    <h3>Select Seat Class</h3>
                    <input type="radio" id="economy" name="seatClass" value="Economy" checked>
                    <label for="economy">Economy</label><br>
                    
                    <input type="radio" id="business" name="seatClass" value="Business">
                    <label for="business">Business</label><br>
                    
                    <input type="radio" id="first" name="seatClass" value="First">
                    <label for="first">First Class</label>
                </div>
                
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