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
    <div class="flex gap-2 w-full pt-2">
        <label class="input flex-1">
            <img src="<%= request.getContextPath()%>/images/icons/assign.png" alt="Search Icon" class="mr-2 w-5 h-5 object-contain" />
            <input type="text" class="grow" placeholder="Search users..." />
        </label>
        <select class="select select-bordered w-40">
            <option value="fullname" selected>Full Name</option>
            <option value="username">Username</option>
        </select>
    </div>

    <dialog id="user_registration_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <b class="text-lg font-bold">User Registration Form</b>
            <p class="py-4 text-gray-500">Press ESC key or click on ✕ button to close</p>
            <p><%=contextPath%></p>
            <form method="post" action="<%= contextPath%>/register">
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Username</legend>
                    <input type="text" name="username" class="input" placeholder="Type unique username of the user" required />
                </fieldset>
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Full Name</legend>
                    <input type="text" name="fullName" class="input" placeholder="Type the Full Name of the user" required />
                </fieldset>
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Password</legend>
                    <input type="password" name="password" class="input" placeholder="Type password" required />
                </fieldset>
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Confirm Password</legend>
                    <input type="password" name="confirmPassword" class="input" placeholder="Type Confirm Password" required />
                </fieldset>
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Role</legend>
                    <select id="roleSelect" name="role" class="select" required onchange="toggleRoleFields()">
                        <option disabled selected value="">Select Role</option>
                        <option value="ADMIN">Admin</option>
                        <option value="ACADEMIC_LEADER">Academic Leader</option>
                        <option value="LECTURER">Lecturer</option>
                        <option value="STUDENT">Student</option>
                    </select>
                </fieldset>

                <fieldset id="programmeIdField" class="fieldset hidden">
                    <legend class="fieldset-legend">Programme ID</legend>
                    <input type="number" name="programmeId" class="input" placeholder="Enter Programme ID" />
                </fieldset>

                <fieldset id="departmentIdField" class="fieldset hidden">
                    <legend class="fieldset-legend">Department ID</legend>
                    <input type="number" name="departmentId" class="input" placeholder="Enter Department ID" />
                </fieldset>

                <div class="form-control mt-6">
                    <button type="submit" class="btn btn-primary text-white">Register User</button>
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


    <jsp:include page="/users?pagination=1" />
</div>
