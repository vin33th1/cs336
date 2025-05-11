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
    
    <%-- (Existing cancellation handling code remains the same) --%>
    <%
    // Handle cancellation before displaying tickets
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("cancelTicket") != null) {
        // ... (keep all the existing cancellation code) ...
    }
    %>

    <%-- Active Tickets Section --%>
    <h3>Active Tickets</h3>
    <%
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
        <p class="error">Error loading your active tickets. Please try again later.</p>
    <%
    } finally {
        if (con != null) con.close();
    }
    %>

    <%-- Used Tickets Section --%>
    <h3 style="margin-top: 30px;">Past Flights</h3>
    <%
    Connection conUsed = null;
    try {
        ApplicationDB dbUsed = new ApplicationDB();    
        conUsed = dbUsed.getConnection();
        
        String username = (String) session.getAttribute("user");
        String usedTicketQuery = "SELECT t.TicketID, f.FlightID, f.FlightNumber, a.AirlineID, " +
                               "f.DepartureAirport, f.DepartureTime, f.ArrivalAirport, f.ArrivalTime, " +
                               "f.FlightDate, t.SeatClass, t.BookingDate, t.Status " +
                               "FROM tickets t " +
                               "JOIN flights f ON t.FlightID = f.FlightID " +
                               "JOIN airlines a ON f.AirlineID = a.AirlineID " +
                               "WHERE t.Username = ? AND t.Status = 'Used' " +
                               "ORDER BY f.FlightDate DESC";
        
        PreparedStatement pstmtUsed = conUsed.prepareStatement(usedTicketQuery);
        pstmtUsed.setString(1, username);
        ResultSet usedTickets = pstmtUsed.executeQuery();
        
        if (!usedTickets.isBeforeFirst()) {
    %>
            <p class="no-tickets">You don't have any past flights.</p>
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
                    <th>Status</th>
                </tr>
                <%
                while (usedTickets.next()) {
                    String departure = usedTickets.getString("DepartureAirport") + " " + usedTickets.getString("DepartureTime");
                    String arrival = usedTickets.getString("ArrivalAirport") + " " + usedTickets.getString("ArrivalTime");
                    String flightDate = usedTickets.getDate("FlightDate").toString();
                    String bookingDate = usedTickets.getTimestamp("BookingDate").toString();
                    String seatClass = usedTickets.getString("SeatClass");
                %>
                <tr>
                    <td><%= usedTickets.getInt("TicketID") %></td>
                    <td><%= usedTickets.getString("AirlineID") %> <%= usedTickets.getString("FlightNumber") %></td>
                    <td><%= departure %></td>
                    <td><%= arrival %></td>
                    <td><%= flightDate %></td>
                    <td><%= seatClass %></td>
                    <td><%= bookingDate %></td>
                    <td>Completed</td>
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
        <p class="error">Error loading your past flights. Please try again later.</p>
    <%
    } finally {
        if (conUsed != null) conUsed.close();
    }
    %>
</div>

<script>
    // (Existing JavaScript code remains the same)
</script>

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
<!-- Questions & Answers Section -->
<div class="qa-section" style="margin-top: 40px; border-top: 1px solid #ddd; padding-top: 20px;">
    <h2>Questions & Answers</h2>
    
    <!-- Search Questions Form -->
    <div class="search-questions" style="margin-bottom: 20px;">
        <h3>Search Questions</h3>
        <form method="get" action="">
            <div class="form-group">
                <input type="text" name="searchQuery" placeholder="Enter keywords..." 
                       value="<%= request.getParameter("searchQuery") != null ? request.getParameter("searchQuery") : "" %>"
                       style="width: 300px; padding: 8px;">
                <input type="submit" value="Search" style="padding: 8px 15px;">
            </div>
        </form>
    </div>
    
    <!-- Post Question Form -->
    <div class="post-question" style="margin-bottom: 30px; border: 1px solid #eee; padding: 15px; background-color: #f9f9f9;">
        <h3>Ask a Question</h3>
        <form method="post" action="">
            <input type="hidden" name="action" value="postQuestion">
            <div class="form-group">
                <textarea name="questionText" rows="4" style="width: 100%; padding: 8px;" 
                          placeholder="Type your question here..." required></textarea>
            </div>
            <div class="form-group">
                <input type="submit" value="Post Question" style="padding: 8px 15px;">
            </div>
        </form>
    </div>
    
    <%
    // Handle question posting
    if ("POST".equalsIgnoreCase(request.getMethod()) && "postQuestion".equals(request.getParameter("action"))) {
        String questionText = request.getParameter("questionText");
        if (questionText != null && !questionText.trim().isEmpty()) {
            Connection conQA = null;
            try {
                ApplicationDB dbQA = new ApplicationDB();    
                conQA = dbQA.getConnection();
                
                String insertQuery = "INSERT INTO questions (Username, QuestionText, Status) VALUES (?, ?, 'Open')";
                PreparedStatement pstmt = conQA.prepareStatement(insertQuery);
                pstmt.setString(1, (String) session.getAttribute("user"));
                pstmt.setString(2, questionText);
                int rowsAffected = pstmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    out.println("<p class='success'>Your question has been posted successfully!</p>");
                } else {
                    out.println("<p class='error'>Failed to post your question. Please try again.</p>");
                }
            } catch (SQLException e) {
                out.println("<p class='error'>Error posting question: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                if (conQA != null) conQA.close();
            }
        }
    }
    
    // Display questions
    Connection conQ = null;
    try {
        ApplicationDB dbQ = new ApplicationDB();    
        conQ = dbQ.getConnection();
        
        String questionQuery = "SELECT q.QuestionID, q.QuestionText, q.PostDate, q.AnswerText, " +
                             "q.AnswerDate, u1.Username AS Asker, u2.Username AS Answerer " +
                             "FROM questions q " +
                             "JOIN users u1 ON q.Username = u1.Username " +
                             "LEFT JOIN users u2 ON q.AnsweredBy = u2.Username " +
                             "WHERE q.Status = 'Answered'";
        
        // Add search filter if search query exists
        String searchQuery = request.getParameter("searchQuery");
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            questionQuery += " AND (q.QuestionText LIKE ? OR q.AnswerText LIKE ?)";
        }
        
        questionQuery += " ORDER BY q.PostDate DESC";
        
        PreparedStatement pstmt = conQ.prepareStatement(questionQuery);
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String likeParam = "%" + searchQuery + "%";
            pstmt.setString(1, likeParam);
            pstmt.setString(2, likeParam);
        }
        
        ResultSet questions = pstmt.executeQuery();
        
        if (!questions.isBeforeFirst()) {
    %>
            <p class="no-questions">No questions found. Be the first to ask a question!</p>
    <%
        } else {
    %>
            <div class="questions-list" style="margin-top: 20px;">
                <h3>Browse Questions</h3>
                <%
                while (questions.next()) {
                    String questionText = questions.getString("QuestionText");
                    String answerText = questions.getString("AnswerText");
                    String postDate = questions.getTimestamp("PostDate").toString();
                    String answerDate = questions.getTimestamp("AnswerDate") != null ? 
                                      questions.getTimestamp("AnswerDate").toString() : "Not answered yet";
                    String answerer = questions.getString("Answerer") != null ? 
                                     questions.getString("Answerer") : "";
                %>
                <div class="question-item" style="border: 1px solid #ddd; padding: 15px; margin-bottom: 15px; border-radius: 5px;">
                    <div class="question" style="margin-bottom: 10px;">
                        <h4 style="margin: 0 0 5px 0;">Question from <%= questions.getString("Asker") %></h4>
                        <p style="font-style: italic; color: #555;"><%= questionText %></p>
                        <p style="font-size: 0.8em; color: #777;">Posted on: <%= postDate %></p>
                    </div>
                    <% if (answerText != null && !answerText.isEmpty()) { %>
                    <div class="answer" style="border-top: 1px solid #eee; padding-top: 10px; margin-top: 10px;">
                        <h4 style="margin: 0 0 5px 0;">Answer from <%= answerer %></h4>
                        <p style="font-style: italic; color: #555;"><%= answerText %></p>
                        <p style="font-size: 0.8em; color: #777;">Answered on: <%= answerDate %></p>
                    </div>
                    <% } %>
                </div>
                <%
                }
                %>
            </div>
    <%
        }
    } catch (SQLException e) {
        e.printStackTrace();
    %>
        <p class="error">Error loading questions. Please try again later.</p>
    <%
    } finally {
        if (conQ != null) conQ.close();
    }
    %>
</div>

<% } %>
</body>
</html>