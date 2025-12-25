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
                <select class="select select-bordered w-full"
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
            </td>
            <td>
                <button class="btn btn-sm btn-primary"
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

        async function saveAssignment(lecturerId) {
            const select = document.getElementById('academicLeader_' + lecturerId);
            const academicLeaderId = select.value;

            try {
                const response = await fetch('<%= request.getContextPath() %>/lecturers', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({
                        lecturerId: lecturerId,
                        academicLeaderId: academicLeaderId
                    })
                });

                if (response.ok) {
                    select.setAttribute('data-original', academicLeaderId);
                    enableSaveButton(lecturerId);
                    alert('Lecturer assignment to Academic Leader updated successfully');
                } else {
                    alert('Failed to update assignment');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('Error updating assignment');
            }
        }
    </script>
</div>
