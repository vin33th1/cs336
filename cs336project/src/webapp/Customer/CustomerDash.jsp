<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
<body>
<h1>Customer Dashboard</h1>

<% if((session.getAttribute("user") == null)) { %>
    You are not logged in <br/>
    <a href="index.jsp">Please Login</a>
<% } else if (!"customer".equals(session.getAttribute("user_type"))) { %>
    You do not have access to this.<br/>
    <a href="index.jsp">Please Login</a>
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
            
            <input type="submit" value="Search Flights">
        </form>
    </div>
<% } %>
</body>
</html>