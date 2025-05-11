<title>Customer Rep Dashboard</title>
<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="com.cs336.pkg.*"%>
    
<h1>Customer Representative Dashboard</h1> <br/>
<% if((session.getAttribute("user") == null)) {%>
    You are not logged in <br/>
    <a href="../index.jsp"> Please Login </a>
<%} else if (!"Representative".equals(session.getAttribute("UserType"))) {%>
    You do not have access to this.<br/>
    <a href="index.jsp">Please Login</a>
<%} else { 
    // Handle question answering
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("answerQuestion") != null) {
        int questionId = Integer.parseInt(request.getParameter("questionId"));
        String answerText = request.getParameter("answerText");
        
        if (answerText != null && !answerText.trim().isEmpty()) {
            Connection con = null;
            try {
                ApplicationDB db = new ApplicationDB();    
                con = db.getConnection();
                
                String updateQuery = "UPDATE questions SET AnswerText = ?, AnsweredBy = ?, " +
                                    "AnswerDate = NOW(), Status = 'Answered' WHERE QuestionID = ?";
                PreparedStatement pstmt = con.prepareStatement(updateQuery);
                pstmt.setString(1, answerText);
                pstmt.setString(2, (String) session.getAttribute("user"));
                pstmt.setInt(3, questionId);
                
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    out.println("<p style='color:green;'>Answer submitted successfully!</p>");
                }
            } catch (SQLException e) {
                out.println("<p style='color:red;'>Error submitting answer: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                if (con != null) con.close();
            }
        }
    }
%>
    Welcome <%=session.getAttribute("user")%> 
    <a href='logout.jsp'>Log out</a>
    
    <div class="question-list">
        <h2>Unanswered Questions</h2>
        <%
        Connection con = null;
        try {
            ApplicationDB db = new ApplicationDB();    
            con = db.getConnection();
            
            // Get unanswered questions
            String query = "SELECT q.*, u.FirstName, u.LastName FROM questions q " +
                          "JOIN users u ON q.Username = u.Username " +
                          "WHERE q.Status = 'Open' " +
                          "ORDER BY q.PostDate DESC";
            
            PreparedStatement pstmt = con.prepareStatement(query);
            ResultSet questions = pstmt.executeQuery();
            
            if (!questions.isBeforeFirst()) {
        %>
                <p>No unanswered questions at this time.</p>
        <%
            } else {
                while (questions.next()) {
        %>
                <div class="question-item">
                    <div class="question-text">
                        <%= questions.getString("QuestionText") %>
                    </div>
                    <div class="question-meta">
                        Asked by: <%= questions.getString("FirstName") %> <%= questions.getString("LastName") %> 
                        (<%= questions.getString("Username") %>) 
                        on <%= questions.getTimestamp("PostDate") %>
                    </div>
                    <form class="answer-form" method="post">
                        <input type="hidden" name="questionId" value="<%= questions.getInt("QuestionID") %>">
                        <textarea name="answerText" rows="4" placeholder="Enter your answer here..." required></textarea>
                        <input type="submit" name="answerQuestion" value="Submit Answer">
                    </form>
                </div>
        <%
                }
            }
            
            // Show recently answered questions
        %>
        <div class="answered-questions">
            <h2>Recently Answered Questions</h2>
            <%
            String answeredQuery = "SELECT q.*, u1.FirstName as AskerFirstName, u1.LastName as AskerLastName, " +
                                 "u2.FirstName as AnswererFirstName, u2.LastName as AnswererLastName " +
                                 "FROM questions q " +
                                 "JOIN users u1 ON q.Username = u1.Username " +
                                 "JOIN users u2 ON q.AnsweredBy = u2.Username " +
                                 "WHERE q.Status = 'Answered' " +
                                 "ORDER BY q.AnswerDate DESC LIMIT 5";
            
            PreparedStatement answeredStmt = con.prepareStatement(answeredQuery);
            ResultSet answeredQuestions = answeredStmt.executeQuery();
            
            if (!answeredQuestions.isBeforeFirst()) {
            %>
                <p>No answered questions yet.</p>
            <%
            } else {
                while (answeredQuestions.next()) {
            %>
                <div class="question-item">
                    <div class="question-text">
                        <%= answeredQuestions.getString("QuestionText") %>
                    </div>
                    <div class="question-meta">
                        Asked by: <%= answeredQuestions.getString("AskerFirstName") %> 
                        <%= answeredQuestions.getString("AskerLastName") %> 
                        on <%= answeredQuestions.getTimestamp("PostDate") %>
                    </div>
                    <div class="answer-text">
                        <strong>Answer:</strong> <%= answeredQuestions.getString("AnswerText") %>
                    </div>
                    <div class="answer-meta">
                        Answered by: <%= answeredQuestions.getString("AnswererFirstName") %> 
                        <%= answeredQuestions.getString("AnswererLastName") %> 
                        on <%= answeredQuestions.getTimestamp("AnswerDate") %>
                    </div>
                </div>
            <%
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        %>
            <p style="color:red;">Error loading questions. Please try again later.</p>
        <%
        } finally {
            if (con != null) con.close();
        }
        %>
        </div>
    </div>
<% } %>