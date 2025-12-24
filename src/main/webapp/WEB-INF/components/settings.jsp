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
    <h2 class="font-title font-bold pb-3 pt-3 text-2xl">System Preferences</h2>
    <p class="text-lg text-gray-500 pr-6 pt-2">Customize your experience</p>
    <div class="card">
        <form>
            <fieldset class="fieldset bg-base-100 border-base-300 rounded-box w-64 border p-4">
                <legend class="fieldset-legend">Appearance</legend>
                <label class="label">
                    <input type="checkbox" checked class="toggle theme-controller" />
                    Dark Mode
                </label>
            </fieldset>
            <div class="form-control mt-6">
                <button type="submit" class="btn btn-primary text-white">Update Preferences</button>
            </div>
        </form>
    </div>
</div>