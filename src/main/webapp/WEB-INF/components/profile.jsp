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
  <h2 class="font-title font-bold pb-3 pt-3 text-2xl">Profile</h2>
  <p class="text-lg text-gray-500 pr-6 pt-2">Manage your profile information</p>
  <div class="card border border-gray-200 bg-base-100 card-l shadow-l max-w-2xl">
    <div class="card-body">
      <form>
        <fieldset class="fieldset">
          <legend class="fieldset-legend">Full Name</legend>
          <input type="text" class="input" placeholder="Type your full name here" />
        </fieldset>
        <fieldset class="fieldset">
          <legend class="fieldset-legend">Personal Email</legend>
          <input type="text" class="input" placeholder="Type your personal email here" />
        </fieldset>
        <fieldset class="fieldset">
          <legend class="fieldset-legend">Phone Number</legend>
          <input type="text" class="input" placeholder="Type your phone number here" />
        </fieldset>
        <fieldset class="fieldset">
          <legend class="fieldset-legend">Address</legend>
          <input type="text" class="input" placeholder="Type your address here" />
        </fieldset>
        <fieldset class="fieldset">
          <legend class="fieldset-legend">Date of Birth</legend>
          <calendar-date class="cally bg-base-100 border border-base-300 shadow-lg rounded-box">
            <svg aria-label="Previous" class="fill-current size-4" slot="previous" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="M15.75 19.5 8.25 12l7.5-7.5"></path></svg>
            <svg aria-label="Next" class="fill-current size-4" slot="next" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="currentColor" d="m8.25 4.5 7.5 7.5-7.5 7.5"></path></svg>
            <calendar-month></calendar-month>
          </calendar-date>
        </fieldset>
        <div class="form-control mt-6">
          <button type="submit" class="btn btn-primary text-white">Update Profile</button>
        </div>
      </form>
    </div>
  </div>
</div>