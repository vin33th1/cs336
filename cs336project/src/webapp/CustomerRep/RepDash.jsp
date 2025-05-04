<title>Customer Rep DashBoard</title>
<h1>Customer Representative DashBoard</h1> <br/>
<% if((session.getAttribute("user") == null)) {%>
	You are not logged in <br/>
	<a href="index.jsp"> Please Login </a>
<%} else if (!"Representative".equals(session.getAttribute("user_type"))) {%>
	You do not have access to this.<br/>
	<a href="index.jsp">Please Login</a>
<%} else {%>
	Welcome <%=session.getAttribute("user")%> 
	<a href='logout.jsp'>Log out</a>
<%}%>

