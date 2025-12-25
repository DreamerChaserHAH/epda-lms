<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.dto.LecturerDTO" %>
<%@ page import="com.htetaung.lms.models.dto.AcademicLeaderDTO" %>
<%@ page import="java.util.List" %>
<%
    List<LecturerDTO> lecturers = (List<LecturerDTO>) request.getAttribute("lecturers");
    List<AcademicLeaderDTO> academicLeaders = (List<AcademicLeaderDTO>) request.getAttribute("academicLeaders");
%>
<div class="overflow-x-auto w-full pt-4">
    <table class="table table-s table-pin-rows table-pin-cols">
        <thead>
        <tr>
            <th>User ID</th>
            <td>Lecturer Name</td>
            <td>Academic Leader</td>
            <td></td>
        </tr>
        </thead>
        <tbody>
        <% if (lecturers != null) {
            for (LecturerDTO lecturer : lecturers) { %>
        <tr>
            <th><%= lecturer.userId %></th>
            <td><%= lecturer.fullname %></td>
            <td>
                <form id="assignmentForm_<%= lecturer.userId %>" method="POST" action="<%= request.getContextPath() %>/lecturers">
                    <input type="hidden" name="_method" value="PUT" />
                    <input type="hidden" name="lecturerId" value="<%= lecturer.userId %>" />
                    <select class="select select-bordered w-full"
                            name="academicLeaderId"
                            id="academicLeader_<%= lecturer.userId %>"
                            data-original="<%= lecturer.academicLeaderUserId != null ? lecturer.academicLeaderUserId : "" %>"
                            onchange="enableSaveButton(<%= lecturer.userId %>)">
                        <option value="">Not Assigned</option>
                        <% if (academicLeaders != null) {
                            for (AcademicLeaderDTO leader : academicLeaders) { %>
                        <option value="<%= leader.userId %>"
                                <%= (lecturer.academicLeaderUserId != null && lecturer.academicLeaderUserId.equals(leader.userId)) ? "selected" : "" %>>
                            <%= leader.fullname %> (<%= leader.numberOfLecturerInCharge %> lecturers)
                        </option>
                        <% }
                        } %>
                    </select>
                </form>
            </td>
            <td>
                <button type="button" class="btn btn-sm btn-primary"
                        id="saveBtn_<%= lecturer.userId %>"
                        onclick="saveAssignment(<%= lecturer.userId %>)"
                        disabled>
                    Save
                </button>
            </td>
        </tr>
        <% }
        } %>
        </tbody>
    </table>

    <script>
        function enableSaveButton(lecturerId) {
            const select = document.getElementById('academicLeader_' + lecturerId);
            const saveBtn = document.getElementById('saveBtn_' + lecturerId);
            const originalValue = select.getAttribute('data-original');

            if (select.value !== originalValue) {
                saveBtn.disabled = false;
                saveBtn.classList.remove('btn-disabled');
            } else {
                saveBtn.disabled = true;
                saveBtn.classList.add('btn-disabled');
            }
        }

        function saveAssignment(lecturerId) {
            const form = document.getElementById('assignmentForm_' + lecturerId);
            form.submit();
        }
    </script>
</div>
