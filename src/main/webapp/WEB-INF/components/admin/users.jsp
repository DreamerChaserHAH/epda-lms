<%--
  Created by IntelliJ IDEA.
  User: victor
  Date: 12/23/25
  Time: 10:08 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.dto.UserDTO" %>
<%@ page import="java.util.List" %>
<%
    String searchQuery = request.getParameter("searchQuery") != null ? request.getParameter("searchQuery") : "";
    String filterField = request.getParameter("filterField") != null ? request.getParameter("filterField") : "fullName";

    List<UserDTO> users = (List<UserDTO>) request.getAttribute("users");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    String contextPath = request.getParameter("contextPath").toString();
%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">User Management</h2>
        <button type="button"
                class="btn btn-primary text-white font-semibold px-4 py-2 rounded-lg transition-colors"
                onclick="user_registration_modal.showModal()"
        >
            Add User
        </button>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">Manage all system users</p>
    <form method="GET" action="<%= request.getContextPath() %>/index.jsp" class="flex gap-2 w-full pt-2">
        <input type="hidden" name="pagination" value="1" />
        <input type="hidden" name="page" value="users" />

        <label class="input flex-1">
            <img src="<%= request.getContextPath()%>/images/icons/assign.png" alt="Search Icon" class="mr-2 w-5 h-5 object-contain" />
            <input type="text"
                   name="searchQuery"
                   class="grow"
                   placeholder="Search users..."
                   value="<%= request.getParameter("searchQuery") != null ? request.getParameter("searchQuery") : "" %>" />
        </label>

        <select name="filterField" class="select select-bordered w-40">
            <option value="fullName" <%= "fullName".equals(request.getParameter("filterField")) || request.getParameter("filterField") == null ? "selected" : "" %>>Full Name</option>
            <option value="username" <%= "username".equals(request.getParameter("filterField")) ? "selected" : "" %>>Username</option>
            <option value="role" <%= "role".equals(request.getParameter("filterField")) ? "selected" : "" %>>Role</option>
        </select>

        <button type="submit" class="btn btn-primary">Search</button>

        <% if (request.getParameter("searchQuery") != null && !request.getParameter("searchQuery").isEmpty()) { %>
        <a href="<%= request.getContextPath() %>/users?pagination=1" class="btn btn-outline">Clear</a>
        <% } %>
    </form>


    <dialog id="user_registration_modal" class="modal">
        <div class="modal-box max-w-4xl max-h-[90vh] overflow-y-auto">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <b class="text-lg font-bold">User Registration Form</b>
            <p class="py-4 text-gray-500">Press ESC key or click on ✕ button to close</p>

            <form method="post" action="<%= contextPath%>/register" class="space-y-6">
                <!-- Personal Information Section -->
                <div class="divider text-primary font-semibold">Personal Information</div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Username *</legend>
                        <input type="text" name="username" class="input input-bordered w-full" placeholder="Type unique username" required />
                    </fieldset>

                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Full Name *</legend>
                        <input type="text" name="fullName" class="input input-bordered w-full" placeholder="Type full name" required />
                    </fieldset>

                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Date of Birth *</legend>
                        <input type="date" name="dateOfBirth" class="input input-bordered w-full" required />
                    </fieldset>

                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Gender *</legend>
                        <select name="gender" class="select select-bordered w-full" required>
                            <option disabled selected value="">Select Gender</option>
                            <option value="MALE">Male</option>
                            <option value="FEMALE">Female</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </fieldset>

                    <fieldset class="fieldset md:col-span-2">
                        <legend class="fieldset-legend">IC/Passport Number *</legend>
                        <input type="text" name="ic" class="input input-bordered w-full" placeholder="Enter IC or Passport Number" required />
                    </fieldset>
                </div>

                <!-- Contact Information Section -->
                <div class="divider text-primary font-semibold">Contact Information</div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Email *</legend>
                        <input type="email" name="email" class="input input-bordered w-full" placeholder="Enter email address" required />
                    </fieldset>

                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Phone Number *</legend>
                        <input type="tel" name="phoneNumber" class="input input-bordered w-full" placeholder="Enter phone number" pattern="[0-9]{10,11}" required />
                    </fieldset>

                    <fieldset class="fieldset md:col-span-2">
                        <legend class="fieldset-legend">Address *</legend>
                        <textarea name="address" class="textarea textarea-bordered w-full" placeholder="Enter full address" rows="3" required></textarea>
                    </fieldset>
                </div>

                <!-- Account Security Section -->
                <div class="divider text-primary font-semibold">Account Security</div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Password *</legend>
                        <input type="password" name="password" class="input input-bordered w-full" placeholder="Type password" required />
                    </fieldset>

                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Confirm Password *</legend>
                        <input type="password" name="confirmPassword" class="input input-bordered w-full" placeholder="Retype password" required />
                    </fieldset>
                </div>

                <!-- Role & Assignment Section -->
                <div class="divider text-primary font-semibold">Role & Assignment</div>

                <div class="grid grid-cols-1 gap-6">
                    <fieldset class="fieldset">
                        <legend class="fieldset-legend">Role *</legend>
                        <select id="roleSelect" name="role" class="select select-bordered w-full" required onchange="toggleRoleFields()">
                            <option disabled selected value="">Select Role</option>
                            <option value="ADMIN">Admin</option>
                            <option value="ACADEMIC_LEADER">Academic Leader</option>
                            <option value="LECTURER">Lecturer</option>
                            <option value="STUDENT">Student</option>
                        </select>
                    </fieldset>

                    <fieldset id="programmeIdField" class="fieldset hidden">
                        <legend class="fieldset-legend">Programme ID</legend>
                        <input type="number" name="programmeId" class="input input-bordered w-full" placeholder="Enter Programme ID" />
                    </fieldset>

                    <fieldset id="departmentIdField" class="fieldset hidden">
                        <legend class="fieldset-legend">Department ID</legend>
                        <input type="number" name="departmentId" class="input input-bordered w-full" placeholder="Enter Department ID" />
                    </fieldset>
                </div>

                <div class="form-control mt-8">
                    <button type="submit" class="btn btn-primary btn-lg text-white w-full">Register User</button>
                </div>
            </form>
        </div>
    </dialog>



    <script>
        function toggleRoleFields() {
            const role = document.getElementById('roleSelect').value;

            const programmeIdField = document.getElementById('programmeIdField');
            const departmentIdField = document.getElementById('departmentIdField');

            // Hide all fields and disable inputs
            [ programmeIdField, departmentIdField].forEach(field => {
                field.classList.add('hidden');
                const input = field.querySelector('input');
                input.value = '';
                input.disabled = true;
                input.removeAttribute('required');
            });

            // Show and enable fields based on role
            if (role === 'STUDENT') {
                // Show Student ID and Programme ID

                programmeIdField.classList.remove('hidden');
                const progInput = programmeIdField.querySelector('input');
                progInput.disabled = false;
                progInput.setAttribute('required', 'required');
            } else if (role === 'LECTURER') {
                // Show Staff Number and Department ID

                departmentIdField.classList.remove('hidden');
                const deptInput = departmentIdField.querySelector('input');
                deptInput.disabled = false;
                deptInput.setAttribute('required', 'required');
            } else if (role === 'ACADEMIC_LEADER') {
                // Show both Department ID and Programme ID
                departmentIdField.classList.remove('hidden');
                const deptInput = departmentIdField.querySelector('input');
                deptInput.disabled = false;
                deptInput.setAttribute('required', 'required');

                programmeIdField.classList.remove('hidden');
                const progInput = programmeIdField.querySelector('input');
                progInput.disabled = false;
                progInput.setAttribute('required', 'required');
            }
        }
    </script>


    <% if(!searchQuery.isEmpty()){ %>
        <jsp:include page="/users?pagination=1">
            <jsp:param name="searchQuery" value="<%= searchQuery %>"/>
            <jsp:param name="filterFiled" value="<%= filterField %>"/>
        </jsp:include>
    <% } else { %>
        <jsp:include page="/users?pagination=1"/>
    <% }  %>
</div>
