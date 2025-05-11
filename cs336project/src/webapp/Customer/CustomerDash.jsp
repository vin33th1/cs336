<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
    <style>
        .form-group { margin-bottom: 10px; }
        label { display: inline-block; width: 150px; }
        .advanced-options { margin-top: 20px; border: 1px solid #ccc; padding: 15px; }
        /* Added styles for tickets section */
        .tickets-section { margin-top: 30px; padding: 20px; border: 1px solid #ddd; border-radius: 5px; }
        .tickets-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .tickets-table th, .tickets-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .tickets-table th { background-color: #f2f2f2; }
        .no-tickets { font-style: italic; color: #666; }
    </style>
</head>
<body>
<h1>Customer Dashboard</h1>

<% if((session.getAttribute("user") == null)) { %>
    You are not logged in <br/>
    <a href="../index.jsp">Please Login</a>
<% } else if (!"Customer".equals(session.getAttribute("UserType"))) { %>
    You do not have access to this.<br/>
    <a href="../index.jsp">Please Login</a>
<% } else { %>
    Welcome <%=session.getAttribute("user")%> 
    <a href='logout.jsp'>Log out</a>
    
    <div class="search-form">
        <h2>Flight Search</h2>
        <form method="get" action="SearchResults.jsp">
            <div class="form-group">
                <label for="OriAirport">Origin Airport:</label>
                <select name="OriAirport" id="OriAirport" required>
                    <option value="">-- Select --</option>
                    <option value="JFK">JFK</option>
                    <option value="LAX">LAX</option>
                    <option value="ATL">ATL</option>
                    <option value="SFO">SFO</option>
                    <option value="ORD">ORD</option>   
                </select>
            </div>
            
            <div class="form-group">
                <label for="DestAirport">Destination Airport:</label>
                <select name="DestAirport" id="DestAirport" required>
                    <option value="">-- Select --</option>
                    <option value="JFK">JFK</option>
                    <option value="LAX">LAX</option>
                    <option value="ATL">ATL</option>
                    <option value="SFO">SFO</option>
                    <option value="ORD">ORD</option>   
                </select>
            </div>
            
            <div class="form-group">
                <label for="tripType">Trip Type:</label>
                <select name="tripType" id="tripType" required>
                    <option value="OneWay">One-Way</option>
                    <option value="RoundTrip">Round-Trip</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="departDate">Departure Date:</label>
                <input type="date" name="departDate" id="departDate" required 
                       min="<%= java.time.LocalDate.now() %>">
            </div>
            
            <div class="form-group" id="returnDateGroup" style="display:none;">
                <label for="returnDate">Return Date:</label>
                <input type="date" name="returnDate" id="returnDate">
            </div>
            
            <div class="form-group">
                <label for="dateFlexibility">Date Flexibility:</label>
                <select name="dateFlexibility" id="dateFlexibility">
                    <option value="0">Exact date only</option>
                    <option value="1">+/- 1 day</option>
                    <option value="2">+/- 2 days</option>
                    <option value="3">+/- 3 days</option>
                </select>
            </div>
            
            <div class="advanced-options">
                <h3>Filter Search</h3>
                <div class="form-group">
                    <label for="maxStops">Max Stops:</label>
                    <select name="maxStops" id="maxStops">
                        <option value="">Any</option>
                        <option value="0">Non-stop only</option>
                        <option value="1">Max 1 stop</option>
                        <option value="2">Max 2 stops</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="airlineFilter">Airline:</label>
                    <select name="airlineFilter" id="airlineFilter">
                        <option value="">Any</option>
                        <option value="AA">American Airlines</option>
                        <option value="DL">Delta</option>
                        <option value="UA">United</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="minPrice">Min Price:</label>
                    <input type="number" name="minPrice" id="minPrice" min="0" step="0.01">
                </div>
                
                <div class="form-group">
                    <label for="maxPrice">Max Price:</label>
                    <input type="number" name="maxPrice" id="maxPrice" min="0" step="0.01">
                </div>
            </div>
            
            <div class="form-group">
                <input type="submit" value="Search Flights">
            </div>
        </form>
    </div>

    <!-- Added Tickets Section -->
   <div class="tickets-section">
    <h2>Your Booked Tickets</h2>
    <%
    // Handle cancellation before displaying tickets
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("cancelTicket") != null) {
        int ticketId = Integer.parseInt(request.getParameter("ticketId"));
        Connection conCancel = null;
        try {
            ApplicationDB dbCancel = new ApplicationDB();    
            conCancel = dbCancel.getConnection();
            
            // First check if the ticket is eligible for cancellation (Business or First class)
            String checkQuery = "SELECT t.SeatClass, t.FlightID FROM tickets t WHERE t.TicketID = ? AND t.Username = ? AND t.Status = 'Active'";
            PreparedStatement checkStmt = conCancel.prepareStatement(checkQuery);
            checkStmt.setInt(1, ticketId);
            checkStmt.setString(2, (String) session.getAttribute("user"));
            ResultSet checkRs = checkStmt.executeQuery();
            
            if (checkRs.next()) {
                String seatClass = checkRs.getString("SeatClass");
                int flightId = checkRs.getInt("FlightID");
                
                if ("Business".equals(seatClass) || "First".equals(seatClass)) {
                    // Update the ticket status to Cancelled
                    String updateQuery = "UPDATE tickets SET Status = 'Cancelled', CancellationDate = NOW() WHERE TicketID = ?";
                    PreparedStatement updateStmt = conCancel.prepareStatement(updateQuery);
                    updateStmt.setInt(1, ticketId);
                    int rowsAffected = updateStmt.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        // Increment the available seats for the flight
                        String incrementSeats = "UPDATE flights SET " + seatClass + "Seats = " + seatClass + "Seats + 1 WHERE FlightID = ?";
                        PreparedStatement incrementStmt = conCancel.prepareStatement(incrementSeats);
                        incrementStmt.setInt(1, flightId);
                        incrementStmt.executeUpdate();
                        
                        out.println("<p class='success'>Ticket #" + ticketId + " has been successfully cancelled.</p>");
                    } else {
                        out.println("<p class='error'>Failed to cancel ticket #" + ticketId + ". Please try again.</p>");
                    }
                } else {
                    out.println("<p class='error'>Only Business or First class tickets can be cancelled.</p>");
                }
            } else {
                out.println("<p class='error'>Ticket not found, already cancelled, or you don't have permission to cancel it.</p>");
            }
        } catch (Exception e) {
            out.println("<p class='error'>Error processing cancellation: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (conCancel != null) conCancel.close();
        }
    }

    // Now display the active tickets
    ApplicationDB db = new ApplicationDB();    
    Connection con = db.getConnection();
    try {
        String username = (String) session.getAttribute("user");
        String ticketQuery = "SELECT t.TicketID, f.FlightID, f.FlightNumber, a.AirlineID, " +
                           "f.DepartureAirport, f.DepartureTime, f.ArrivalAirport, f.ArrivalTime, " +
                           "f.FlightDate, t.SeatClass, t.BookingDate, t.Status " +
                           "FROM tickets t " +
                           "JOIN flights f ON t.FlightID = f.FlightID " +
                           "JOIN airlines a ON f.AirlineID = a.AirlineID " +
                           "WHERE t.Username = ? AND t.Status = 'Active' " +
                           "ORDER BY t.BookingDate DESC";
        
        PreparedStatement pstmt = con.prepareStatement(ticketQuery);
        pstmt.setString(1, username);
        ResultSet tickets = pstmt.executeQuery();
        
        if (!tickets.isBeforeFirst()) {
    %>
            <p class="no-tickets">You don't have any active tickets.</p>
    <%
        } else {
    %>
            <table class="tickets-table">
                <tr>
                    <th>Ticket ID</th>
                    <th>Flight</th>
                    <th>Departure</th>
                    <th>Arrival</th>
                    <th>Date</th>
                    <th>Class</th>
                    <th>Booked On</th>
                    <th>Action</th>
                </tr>
                <%
                while (tickets.next()) {
                    String departure = tickets.getString("DepartureAirport") + " " + tickets.getString("DepartureTime");
                    String arrival = tickets.getString("ArrivalAirport") + " " + tickets.getString("ArrivalTime");
                    String flightDate = tickets.getDate("FlightDate").toString();
                    String bookingDate = tickets.getTimestamp("BookingDate").toString();
                    String seatClass = tickets.getString("SeatClass");
                    int ticketId = tickets.getInt("TicketID");
                %>
                <tr>
                    <td><%= ticketId %></td>
                    <td><%= tickets.getString("AirlineID") %> <%= tickets.getString("FlightNumber") %></td>
                    <td><%= departure %></td>
                    <td><%= arrival %></td>
                    <td><%= flightDate %></td>
                    <td><%= seatClass %></td>
                    <td><%= bookingDate %></td>
                    <td>
                        <% if ("Business".equals(seatClass) || "First".equals(seatClass)) { %>
                            <form method="post" style="display:inline;">
                                <input type="hidden" name="ticketId" value="<%= ticketId %>">
                                <input type="submit" name="cancelTicket" value="Cancel" class="cancel-btn" 
                                       onclick="return confirm('Are you sure you want to cancel this ticket?');">
                            </form>
                        <% } else { %>
                            &nbsp;
                        <% } %>
                    </td>
                </tr>
                <%
                }
                %>
            </table>
    <%
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
        <p class="error">Error loading your tickets. Please try again later.</p>
    <%
    } finally {
        if (con != null) con.close();
    }
    %>
</div>

<script>
    // Show/hide return date based on trip type
    document.getElementById('tripType').addEventListener('change', function() {
        var returnDateGroup = document.getElementById('returnDateGroup');
        if (this.value === 'RoundTrip') {
            returnDateGroup.style.display = 'block';
            document.getElementById('returnDate').required = true;
        } else {
            returnDateGroup.style.display = 'none';
            document.getElementById('returnDate').required = false;
        }
    });
    
    // Set minimum return date based on departure date
    document.getElementById('departDate').addEventListener('change', function() {
        var returnDate = document.getElementById('returnDate');
        returnDate.min = this.value;
        if (returnDate.value && returnDate.value < this.value) {
            returnDate.value = this.value;
        }
    });
</script>
<% } %>
</body>
</html>