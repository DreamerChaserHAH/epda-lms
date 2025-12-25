<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.dto.UserDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<UserDTO> users = (List<UserDTO>) request.getAttribute("users");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
%>
<div class="overflow-x-auto w-full pt-4">
    <table class="table table-s table-pin-rows table-pin-cols">
        <thead>
        <tr>
            <th>ID</th>
            <td>Username</td>
            <td>Full Name</td>
            <td>Date of Birth</td>
            <td>Email</td>
            <td>Phone</td>
            <td>Gender</td>
            <td>Role</td>
            <td>Registered On</td>
            <td></td>
        </tr>
        </thead>
        <tbody>
        <% if (users != null) {
            for (UserDTO user : users) { %>
        <tr>
            <th><%= user.userId %></th>
            <td><%= user.username %></td>
            <td><%= user.fullName %></td>
            <td><%= dateFormat.format(user.dateOfBirth) %></td>
            <td><%= user.email %></td>
            <td><%= user.phoneNumber %></td>
            <td><%= user.gender %></td>
            <td><%= user.role %></td>
            <td><%= user.registeredOn %></td>
            <td class="flex gap-2">
                <button class="btn btn-sm btn-outline"
                        onclick="showEditModal(
                                '<%= user.userId %>',
                                '<%= user.username %>',
                                '<%= user.fullName %>',
                                '<%= dateFormat.format(user.dateOfBirth) %>',
                                '<%= user.ic %>',
                                '<%= user.email %>',
                                '<%= user.phoneNumber %>',
                                '<%= user.address.replace("'", "\\'").replace("\n", "\\n") %>',
                                '<%= user.gender %>',
                                '<%= user.role %>')">
                    Edit
                </button>
                <button class="btn btn-sm btn-outline btn-error"
                        onclick="showDeleteConfirmation('<%= user.userId %>', '<%= user.username %>', '<%= user.fullName %>')">
                    Delete
                </button>
            </td>
        </tr>
        <% }
        } %>
        </tbody>
    </table>

    <dialog id="edit_user_modal" class="modal">
        <div class="modal-box max-w-4xl max-h-[90vh] overflow-y-auto">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Edit User</h3>

            <form id="editUserForm" method="POST" action="<%= request.getContextPath() %>/users" class="py-4 space-y-6" onsubmit="return validateEditForm()">
                <input type="hidden" name="_method" value="PUT" />
                <input type="hidden" id="editUserId" name="userId" />

                <!-- Personal Information -->
                <div class="divider text-primary font-semibold">Personal Information</div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Username *</span>
                        </label>
                        <input type="text" id="editUsername" name="username" class="input input-bordered w-full" required />
                    </div>

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Full Name *</span>
                        </label>
                        <input type="text" id="editFullName" name="fullName" class="input input-bordered w-full" required />
                    </div>

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Date of Birth *</span>
                        </label>
                        <input type="date" id="editDateOfBirth" name="dateOfBirth" class="input input-bordered w-full" required />
                    </div>

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Gender *</span>
                        </label>
                        <select id="editGender" name="gender" class="select select-bordered w-full" required>
                            <option value="MALE">Male</option>
                            <option value="FEMALE">Female</option>
                            <option value="OTHER">Other</option>
                        </select>
                    </div>

                    <div class="form-control md:col-span-2">
                        <label class="label">
                            <span class="label-text">IC/Passport Number *</span>
                        </label>
                        <input type="text" id="editIc" name="ic" class="input input-bordered w-full" required />
                    </div>
                </div>

                <!-- Contact Information -->
                <div class="divider text-primary font-semibold">Contact Information</div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Email *</span>
                        </label>
                        <input type="email" id="editEmail" name="email" class="input input-bordered w-full" required />
                    </div>

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Phone Number *</span>
                        </label>
                        <input type="tel" id="editPhoneNumber" name="phoneNumber" class="input input-bordered w-full" pattern="[0-9]{10,11}" required />
                    </div>

                    <div class="form-control md:col-span-2">
                        <label class="label">
                            <span class="label-text">Address *</span>
                        </label>
                        <textarea id="editAddress" name="address" class="textarea textarea-bordered w-full" rows="3" required></textarea>
                    </div>
                </div>

                <!-- Role -->
                <div class="divider text-primary font-semibold">Role</div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Role *</span>
                    </label>
                    <select id="editRole" name="role" class="select select-bordered w-full" required>
                        <option value="STUDENT">Student</option>
                        <option value="LECTURER">Lecturer</option>
                        <option value="ACADEMIC_LEADER">Academic Leader</option>
                        <option value="ADMIN">Admin</option>
                    </select>
                </div>

                <!-- Password Change (Optional) -->
                <div class="divider text-primary font-semibold">Change Password (Optional)</div>

                <div class="form-control mb-4">
                    <label class="label cursor-pointer justify-start gap-2">
                        <input type="checkbox" id="changePasswordCheckbox" class="checkbox checkbox-primary" />
                        <span class="label-text">Change user password</span>
                    </label>
                </div>

                <div id="passwordFields" class="grid grid-cols-1 md:grid-cols-2 gap-6 hidden">
                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">New Password</span>
                        </label>
                        <input type="password" id="editPassword" name="password" class="input input-bordered w-full" placeholder="Enter new password" minlength="6" />
                    </div>

                    <div class="form-control">
                        <label class="label">
                            <span class="label-text">Confirm New Password</span>
                        </label>
                        <input type="password" id="editConfirmPassword" class="input input-bordered w-full" placeholder="Confirm new password" />
                    </div>
                </div>

                <div class="modal-action mt-8">
                    <button type="button" onclick="edit_user_modal.close()" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update User</button>
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
            </div>

            <div class="modal-action">
                <form method="POST" action="<%= request.getContextPath() %>/users" class="flex gap-2">
                    <input type="hidden" name="_method" value="DELETE" />
                    <input type="hidden" id="deleteUserId" name="userId" />
                    <button type="button" onclick="delete_confirmation_modal.close()" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-error text-white">Delete User</button>
                </form>
            </div>
        </div>
    </dialog>

    <script>
        function showDeleteConfirmation(userId, username, fullName) {
            document.getElementById('deleteUserId').value = userId;
            document.getElementById('deleteUsername').textContent = username;
            document.getElementById('deleteFullName').textContent = fullName;
            delete_confirmation_modal.showModal();
        }

        function showEditModal(userId, username, fullName, dateOfBirth, ic, email, phoneNumber, address, gender, role) {
            document.getElementById('editUserId').value = userId;
            document.getElementById('editUsername').value = username;
            document.getElementById('editFullName').value = fullName;

            if (dateOfBirth && dateOfBirth.trim() !== '') {
                const parts = dateOfBirth.split('/');
                if (parts.length === 3) {
                    const day = parts[0].padStart(2, '0');
                    const month = parts[1].padStart(2, '0');
                    const year = parts[2];
                    document.getElementById('editDateOfBirth').value = year + '-' + month + '-' + day;
                }
            }

            document.getElementById('editIc').value = ic;
            document.getElementById('editEmail').value = email;
            document.getElementById('editPhoneNumber').value = phoneNumber;
            document.getElementById('editAddress').value = address;
            document.getElementById('editGender').value = gender;
            document.getElementById('editRole').value = role;

            document.getElementById('changePasswordCheckbox').checked = false;
            document.getElementById('passwordFields').classList.add('hidden');
            document.getElementById('editPassword').value = '';
            document.getElementById('editConfirmPassword').value = '';
            document.getElementById('editPassword').removeAttribute('required');
            document.getElementById('editConfirmPassword').removeAttribute('required');

            edit_user_modal.showModal();
        }

        function validateEditForm() {
            const changePassword = document.getElementById('changePasswordCheckbox').checked;
            if (changePassword) {
                const password = document.getElementById('editPassword').value;
                const confirmPassword = document.getElementById('editConfirmPassword').value;

                if (password !== confirmPassword) {
                    alert('Passwords do not match');
                    return false;
                }
                if (password.length < 6) {
                    alert('Password must be at least 6 characters');
                    return false;
                }
            } else {
                document.getElementById('editPassword').removeAttribute('name');
            }
            return true;
        }

        document.getElementById('changePasswordCheckbox').addEventListener('change', function() {
            const passwordFields = document.getElementById('passwordFields');
            const passwordInput = document.getElementById('editPassword');
            const confirmPasswordInput = document.getElementById('editConfirmPassword');

            if (this.checked) {
                passwordFields.classList.remove('hidden');
                passwordInput.setAttribute('required', 'required');
                confirmPasswordInput.setAttribute('required', 'required');
            } else {
                passwordFields.classList.add('hidden');
                passwordInput.removeAttribute('required');
                confirmPasswordInput.removeAttribute('required');
                passwordInput.value = '';
                confirmPasswordInput.value = '';
            }
        });
    </script>
</div>
