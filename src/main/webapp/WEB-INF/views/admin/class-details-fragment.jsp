<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.ClassDTO" %>
<%@ page import="com.htetaung.lms.models.dto.StudentDTO" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    ClassDTO classDTO = (ClassDTO) request.getAttribute("classDetails");
    List<StudentDTO> availableStudents = (List<StudentDTO>) request.getAttribute("availableStudents");
    String contextPath = request.getContextPath();

    if (classDTO == null) {
        request.setAttribute("includingPage", "/WEB-INF/views/admin/class-details-fragment.jsp");
        request.setAttribute("classId", request.getParameter("classId"));
        request.getRequestDispatcher("/classes").include(request, response);
        return;
    }
%>

<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Class Details: <%= classDTO.className %></h2>
        <div class="flex gap-2">
            <button type="button"
                    class="btn btn-error text-white font-semibold px-6 py-2 rounded-lg hover:scale-105 transition-transform duration-200"
                    onclick="delete_class_modal.showModal()">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                Delete Class
            </button>
            <button type="button"
                    class="btn btn-primary text-white font-semibold px-6 py-2 rounded-lg hover:scale-105 transition-transform duration-200"
                    onclick="add_student_modal.showModal()">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Add Student
            </button>
        </div>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">
        Manage students enrolled in this class
    </p>

    <!-- Class Information Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6 mt-6">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">Class Information</h3>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Class Name</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.className %>
                    </div>
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Module</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.moduleDTO.moduleName %>
                    </div>
                </div>

                <% if (classDTO.moduleDTO.managedBy != null) { %>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Lecturer</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <%= classDTO.moduleDTO.managedBy.fullname %>
                    </div>
                </div>
                <% } %>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Total Students</span>
                    </label>
                    <div class="input input-bordered flex items-center bg-base-200">
                        <div class="badge badge-primary badge-lg font-semibold">
                            <%= classDTO.studentCount != null ? classDTO.studentCount : 0 %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Students Table Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300">
        <div class="card-body">
            <h3 class="card-title text-primary mb-4">Enrolled Students</h3>

            <% if (classDTO.students != null && !classDTO.students.isEmpty()) { %>
            <div class="overflow-x-auto">
                <table class="table table-zebra">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Student ID</th>
                        <th>Full Name</th>
                        <th>Email</th>
                        <th>Phone Number</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        int index = 1;
                        for (StudentDTO student : classDTO.students) {
                    %>
                    <tr>
                        <td><%= index++ %></td>
                        <td><%= student.userId %></td>
                        <td>
                            <div class="flex items-center gap-3">
                                <div class="avatar placeholder">
                                    <div class="bg-primary text-primary-content rounded-full w-8">
                                        <span class="text-xs"><%= student.fullname.substring(0, 1).toUpperCase() %></span>
                                    </div>
                                </div>
                                <div>
                                    <div class="font-bold"><%= student.fullname %></div>
                                </div>
                            </div>
                        </td>
                        <td><%= student.email %></td>
                        <td><%= student.phoneNumber %></td>
                        <td>
                            <button type="button"
                                    class="btn btn-error btn-sm text-white font-semibold"
                                    onclick="confirmRemoveStudent(<%= student.userId %>, '<%= student.fullname %>')">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                </svg>
                                Remove
                            </button>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <div class="alert alert-info">
                <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span>No students enrolled in this class yet. Click "Add Student" to enroll students.</span>
            </div>
            <% } %>
        </div>
    </div>
</div>

<!-- Add Student Modal -->
<dialog id="add_student_modal" class="modal">
    <div class="modal-box max-w-md">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>
        <h3 class="font-bold text-2xl mb-6 text-base-content">Add Student to Class</h3>

        <form method="POST" action="<%= contextPath %>/classes">
            <input type="hidden" name="_method" value="PUT">
            <input type="hidden" name="classId" value="<%= classDTO.classId %>">
            <input type="hidden" name="className" value="<%= classDTO.className %>">

            <div class="form-control">
                <label class="label">
                    <span class="label-text font-semibold text-base-content">Select Student</span>
                </label>
                <select name="studentsToAdd[]" class="select select-bordered w-full focus:select-primary" required>
                    <option value="" disabled selected>Choose a student</option>
                    <% if (availableStudents != null && !availableStudents.isEmpty()) {
                        for (StudentDTO student : availableStudents) { %>
                    <option value="<%= student.userId %>">
                        <%= student.fullname %> (<%= student.userId %>)
                    </option>
                    <% }
                    } %>
                </select>
            </div>

            <div class="modal-action mt-6">
                <button type="button" class="btn btn-ghost font-semibold" onclick="add_student_modal.close()">Cancel</button>
                <button type="submit" class="btn btn-primary text-white font-semibold px-6 rounded-lg hover:scale-105 transition-transform">
                    Add Student
                </button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<!-- Remove Student Confirmation Modal -->
<dialog id="remove_student_modal" class="modal">
    <div class="modal-box">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>
        <h3 class="font-bold text-lg text-error mb-4">Remove Student</h3>
        <p class="py-4">Are you sure you want to remove <span id="studentNameToRemove" class="font-bold"></span> from this class?</p>

        <form method="POST" action="<%= contextPath %>/classes" id="removeStudentForm">
            <input type="hidden" name="_method" value="PUT">
            <input type="hidden" name="classId" value="<%= classDTO.classId %>">
            <input type="hidden" name="className" value="<%= classDTO.className %>">
            <input type="hidden" name="studentsToRemove[]" id="studentIdToRemove">

            <div class="modal-action">
                <button type="button" class="btn btn-ghost" onclick="remove_student_modal.close()">Cancel</button>
                <button type="submit" class="btn btn-error text-white">Remove Student</button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<!-- Delete Class Confirmation Modal -->
<dialog id="delete_class_modal" class="modal">
    <div class="modal-box">
        <form method="dialog">
            <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
        </form>
        <h3 class="font-bold text-lg text-error mb-4">Delete Class</h3>
        <p class="py-4">Are you sure you want to delete <span class="font-bold"><%= classDTO.className %></span>? This action cannot be undone.</p>

        <form method="POST" action="<%= contextPath %>/classes">
            <input type="hidden" name="_method" value="DELETE">
            <input type="hidden" name="classId" value="<%= classDTO.classId %>">

            <div class="modal-action">
                <button type="button" class="btn btn-ghost" onclick="delete_class_modal.close()">Cancel</button>
                <button type="submit" class="btn btn-error text-white">Delete Class</button>
            </div>
        </form>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<script>
    function confirmRemoveStudent(studentId, studentName) {
        document.getElementById('studentIdToRemove').value = studentId;
        document.getElementById('studentNameToRemove').textContent = studentName;
        remove_student_modal.showModal();
    }
</script>
