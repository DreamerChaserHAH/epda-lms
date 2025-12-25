<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.LecturerDTO" %>
<%@ page import="java.util.List" %>
<%
    // Retrieve lecturers set by the servlet
    List<LecturerDTO> lecturers = (List<LecturerDTO>) request.getAttribute("lecturers");
    String contextPath = request.getContextPath();
%>

<dialog id="create_module_modal" class="modal">
    <div class="modal-box">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>
        <h3 class="text-lg font-bold">Create New Module</h3>
        <p class="py-4 text-gray-500">Press ESC key or click on ✕ button to close</p>

        <form method="POST" action="<%= contextPath %>/modules" class="space-y-4">
            <fieldset class="fieldset">
                <legend class="fieldset-legend">Module Name *</legend>
                <input type="text"
                       name="moduleName"
                       class="input input-bordered w-full"
                       placeholder="Enter module name"
                       required />
            </fieldset>

            <fieldset class="fieldset">
                <legend class="fieldset-legend">Assign Lecturer *</legend>
                <select name="lecturerId" class="select select-bordered w-full" required>
                    <option disabled selected value="">Select Lecturer</option>
                    <% if (lecturers != null) {
                        for (LecturerDTO lecturer : lecturers) { %>
                    <option value="<%= lecturer.userId %>"><%= lecturer.fullname %></option>
                    <% }
                    } %>
                </select>
            </fieldset>

            <div class="modal-action">
                <button type="button" onclick="create_module_modal.close()" class="btn btn-outline">Cancel</button>
                <button type="submit" class="btn btn-primary">Create Module</button>
            </div>
        </form>
    </div>
</dialog>
