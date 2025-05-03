<%@ page import ="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>

<title>Customer DashBoard</title>
<h1>Customer DashBoard</h1> <br/>
<% if((session.getAttribute("user") == null)) {%>
	You are not logged in <br/>
	<a href="index.jsp"> Please Login </a>
<%} else if (!"customer".equals(session.getAttribute("user_type"))) {%>
	You do not have access to this.<br/>
	<a href="index.jsp">Please Login</a>
<%} else {%>
	Welcome <%=session.getAttribute("user")%> 
	<a href='logout.jsp'>Log out</a>
<%}%>

<h2>Flight Search</h2>

Origin Airport:
<select>
    <option>JFK</option>
    <option>EWR</option>
    <option>LAX</option>
</select>

Destination Airport:
<select>
    <option>JFK</option>
    <option>EWR</option>
    <option>LAX</option>
</select>

Trip Type:
<select name = "tripType]">
    <option>One-Way</option>
    <option>RoundTrip</option>
</select>

<button>Search</button>