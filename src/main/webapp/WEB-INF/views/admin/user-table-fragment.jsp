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
                <button class="btn btn-outline">
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

    </script>
</div>
