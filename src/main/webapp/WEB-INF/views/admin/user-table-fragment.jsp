<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.dto.UserDTO" %>
<%@ page import="java.util.List" %>
<%
    List<UserDTO> users = (List<UserDTO>) request.getAttribute("users");
%>
<div class="overflow-x-auto w-full pt-4">
    <table class="table table-s table-pin-rows table-pin-cols">
        <thead>
        <tr>
            <th></th>
            <td>Username</td>
            <td>Full Name</td>
            <td>Role</td>
            <td>Registered On</td>
            <td></td>
            <th></th>
        </tr>
        </thead>
        <tbody>
        <% if (users != null) {
            int index = 1;
            for (UserDTO user : users) { %>
        <tr>
            <th><%= user.userId %></th>
            <td><%= user.username %></td>
            <td><%= user.fullName %></td>
            <td><%= user.role %></td>
            <td><%= user.registeredOn %></td>
            <td class="flex gap-2">
                <button class="btn btn-outline"
                        onclick="showEditModal('<%= user.userId %>', '<%= user.username %>', '<%= user.fullName %>', '<%= user.role %>')">
                    Edit
                </button>
                <button class="btn btn-outline btn-error"
                        onclick="showDeleteConfirmation('<%= user.userId %>', '<%= user.username %>', '<%= user.fullName %>', '<%= user.role %>')">
                    Delete
                </button>
            </td>
            <th><%= user.userId %></th>
        </tr>
        <% }
        } %>
        </tbody>
    </table>

    <dialog id="edit_user_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Edit User</h3>

            <form id="editUserForm" method="POST" action="<%= request.getContextPath() %>/users" class="py-4">
                <input type="hidden" name="_method" value="PUT" />
                <input type="hidden" id="editUserId" name="userId" />

                <% if (request.getParameter("searchQuery") != null) { %>
                <input type="hidden" name="searchQuery" value="<%= request.getParameter("searchQuery") %>" />
                <% } %>
                <% if (request.getParameter("filterField") != null) { %>
                <input type="hidden" name="filterField" value="<%= request.getParameter("filterField") %>" />
                <% } %>
                <% if (request.getParameter("pagination") != null) { %>
                <input type="hidden" name="pagination" value="<%= request.getParameter("pagination") %>" />
                <% } %>

                <div class="form-control w-full mb-4">
                    <label class="label">
                        <span class="label-text">Username</span>
                    </label>
                    <input type="text"
                           id="editUsername"
                           name="username"
                           class="input input-bordered w-full"
                           required />
                </div>

                <div class="form-control w-full mb-4">
                    <label class="label">
                        <span class="label-text">Full Name</span>
                    </label>
                    <input type="text"
                           id="editFullName"
                           name="fullName"
                           class="input input-bordered w-full"
                           required />
                </div>

                <div class="form-control w-full mb-4">
                    <label class="label">
                        <span class="label-text">Role</span>
                    </label>
                    <select id="editRole"
                            name="role"
                            class="select select-bordered w-full"
                            required>
                        <option value="student">Student</option>
                        <option value="lecturer">Lecturer</option>
                        <option value="academic_leader">Academic Leader</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>

                <div class="modal-action">
                    <button type="button" onclick="edit_user_modal.close()" class="btn btn-outline">Cancel</button>
                    <button type="button" id="confirmEditBtn" class="btn btn-primary">Update User</button>
                </div>
            </form>
        </div>
    </dialog>
    <dialog id="delete_confirmation_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Confirm Deletion</h3>
            <p class="py-4 text-gray-500">Are you sure you want to delete this user? This action cannot be undone.</p>

            <div id="userDetailsToDelete" class="bg-base-200 p-4 rounded-lg mb-4">
                <p><strong>Username:</strong> <span id="deleteUsername"></span></p>
                <p><strong>Full Name:</strong> <span id="deleteFullName"></span></p>
                <p><strong>Role:</strong> <span id="deleteRole"></span></p>
            </div>

            <div class="modal-action">
                <form method="dialog" class="flex gap-2">
                    <button class="btn btn-outline">Cancel</button>
                    <button type="button" id="confirmDeleteBtn" class="btn btn-error text-white">Delete User</button>
                </form>
            </div>
        </div>
    </dialog>

    <script>
        let userIdToDelete = null;

        function showDeleteConfirmation(userId, username, fullName, role) {
            userIdToDelete = userId;

            // Populate modal with user details
            document.getElementById('deleteUsername').textContent = username;
            document.getElementById('deleteFullName').textContent = fullName;
            document.getElementById('deleteRole').textContent = role;

            // Show modal
            delete_confirmation_modal.showModal();
        }

        function showEditModal(userId, username, fullName, role) {
            // Populate form fields
            document.getElementById('editUserId').value = userId;
            document.getElementById('editUsername').value = username;
            document.getElementById('editFullName').value = fullName;
            document.getElementById('editRole').value = role.toLowerCase();

            // Show modal
            edit_user_modal.showModal();
        }

        document.getElementById('confirmDeleteBtn').addEventListener('click', async function() {
            if (userIdToDelete) {
                try {
                    const response = await fetch('<%= request.getContextPath() %>/users?userId=' + userIdToDelete, {
                        method: 'DELETE'
                    });

                    if (response.ok) {
                        window.location.reload(); // Reload to see changes
                    } else {
                        alert('Failed to delete user');
                    }
                } catch (error) {
                    console.error('Error:', error);
                    alert('Error deleting user');
                }
            }
        });

        document.getElementById('confirmEditBtn').addEventListener('click', function() {
            const form = document.getElementById('editUserForm');

            // Get form values
            const userId = document.getElementById('editUserId').value;
            const username = document.getElementById('editUsername').value;
            const fullName = document.getElementById('editFullName').value;
            const role = document.getElementById('editRole').value;

            // Validate required fields
            if (!username || !fullName || !role) {
                alert('Please fill in all required fields');
                return;
            }

            // Build URL parameters
            const params = new URLSearchParams({
                userId: userId,
                username: username,
                fullName: fullName,
                role: role
            });

            // Preserve search/filter parameters
            const searchQuery = '<%= request.getParameter("searchQuery") != null ? request.getParameter("searchQuery") : "" %>';
            const filterField = '<%= request.getParameter("filterField") != null ? request.getParameter("filterField") : "" %>';
            const pagination = '<%= request.getParameter("pagination") != null ? request.getParameter("pagination") : "" %>';

            if (searchQuery) params.append('searchQuery', searchQuery);
            if (filterField) params.append('filterField', filterField);
            if (pagination) params.append('pagination', pagination);

            // Send PUT request
            fetch('<%= request.getContextPath() %>/users?' + params.toString(), {
                method: 'PUT'
            })
                .then(response => {
                    if (response.ok) {
                        window.location.reload(); // Reload to see changes
                    } else {
                        alert('Failed to update user');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Error updating user');
                });
        });

    </script>
</div>
