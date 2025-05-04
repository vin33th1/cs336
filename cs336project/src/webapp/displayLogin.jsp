<%@ page import ="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
<%
	String username = request.getParameter("username");
	String pwd = request.getParameter("password");
	
	ApplicationDB db = new ApplicationDB();
	Connection con = db.getConnection();
	Statement st = con.createStatement();
	ResultSet rs;
	
	rs = st.executeQuery("select * from users where username='" + username + "' and password='" + pwd
	+ "'");
	if (rs.next()) {
		session.setAttribute("user", username); // the username will be stored in the session
		session.setAttribute("UserType", rs.getString("UserType")); // also stores user_type in the session
		
		String userType= rs.getString("UserType");
		if("Admin".equals(userType)) {
			response.sendRedirect("Admin/AdminDash.jsp");
		} else if ("Representative".equals(userType)) {
			response.sendRedirect("CustomerRep/RepDash.jsp");
		} else if ("Customer".equals(userType)) {
			response.sendRedirect("Customer/CustomerDash.jsp");
		}
		else{
			out.println("Invalid Credentials <a href = index.jsp> try again</a>");
			out.println(userType);
		}
		
		
	} else {
		out.println("Invalid password <a href='index.jsp'>try again</a>");
	}
%>