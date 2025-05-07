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
                <h3>Advanced Options</h3>
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