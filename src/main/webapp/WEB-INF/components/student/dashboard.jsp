<%--
  Created by IntelliJ IDEA.
  User: victor
  Date: 12/23/25
  Time: 3:29 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Check if user is authenticated
    if (session.getAttribute("authenticated") == null ||
            !(Boolean)session.getAttribute("authenticated")) {
        return;
    }

    String username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "STUDENT";
%>
<div>
    <div class="flex flex-row gap-6 w-full pb-4">
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Enrolled Modules</b>
                <p class="text-3xl font-bold">12</p>
            </div>
        </div>
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Total Assessments</b>
                <p class="text-3xl font-bold">12</p>
            </div>
        </div>
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <div class="card-body">
                <b class="card-title text-gray-500">Completed Assessments</b>
                <p class="text-3xl font-bold">12</p>
            </div>
        </div>
    </div>

    <div class="flex flex-row gap-6 w-full pb-4">
        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <a href="<%=request.getContextPath()%>/index.jsp?page=profile">
                <div class="card-body">
                    <div class="avatar">
                        <div class="w-24 rounded">
                            <img src="<%= request.getContextPath()%>/images/icons/profile.png" />
                        </div>
                    </div>
                    <b class="card-title">Edit Profile</b>
                    <p>Update your personal information</p>
                </div>
            </a>
        </div>

        <div class="card border border-gray-200 bg-base-100 card-l shadow-l flex-1">
            <a href="<%=request.getContextPath()%>/index.jsp?page=results">
                <div class="card-body">
                    <div class="avatar">
                        <div class="w-24 rounded">
                            <img src="<%= request.getContextPath()%>/images/icons/results.png" />
                        </div>
                    </div>
                    <b class="card-title">View Results</b>
                    <p>Check your assessment grades</p>
                </div>
            </a>
        </div>
    </div>

    <h2 class="font-title font-bold pb-3 pt-3 text-2xl">My Modules</h2>
    <div>
        <div class="flex flex-row flex-wrap gap-6">
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
            <div class="card border border-gray-200 w-128 bg-base-100 card-l shadow-l">
                <div class="card-body">
                    <b class="card-title text-gray-500">CS101</b>
                    <p class="text-2xl font-bold">Introduction to Computer Science</p>
                    <p>Lecturer: XXX</p>
                    <p>Schedule: Mon/Wed 10:00-12:00</p>
                </div>
            </div>
        </div>
    </div>
</div>
