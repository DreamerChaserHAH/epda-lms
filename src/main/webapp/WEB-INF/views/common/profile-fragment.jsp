<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.UserDTO" %>
<%@ page import="com.htetaung.lms.models.enums.UserRole" %>
<%@ page import="com.htetaung.lms.models.enums.Gender" %>
<%@ page import="java.text.SimpleDateFormat" %>
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

  Long currentUserId = (Long) session.getAttribute("userId");
  UserDTO user = (UserDTO) request.getAttribute("userProfile");
  String contextPath = request.getContextPath();

  // Check if viewing own profile
  boolean isOwnProfile = currentUserId.equals(user.userId);

  // Format date for display and input
  SimpleDateFormat displayFormat = new SimpleDateFormat("dd MMM yyyy");
  SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd");
  String dateDisplay = displayFormat.format(user.dateOfBirth);
  String dateInput = inputFormat.format(user.dateOfBirth);
%>
<div>
  <div class="flex items-center justify-between pb-3 pt-3">
    <h2 class="font-title font-bold text-2xl">Profile of <%= user.fullName %></h2>
    <% if (isOwnProfile) { %>
    <button type="button"
            class="btn btn-outline btn-sm"
            onclick="change_password_modal.showModal()">
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" />
      </svg>
      Change Password
    </button>
    <% } %>
  </div>
  <p class="text-lg text-gray-500 pr-6 pt-2">
    <%= isOwnProfile ? "Manage your profile information" : "View user profile information" %>
  </p>

  <form id="profileForm" method="POST" action="<%= contextPath %>/users" class="mt-6">
    <input type="hidden" name="_method" value="PUT" />
    <input type="hidden" name="userId" value="<%= user.userId %>" />
    <input type="hidden" name="username" value="<%= user.username %>" />
    <input type="hidden" name="role" value="<%= user.role %>" />

    <!-- Personal Information Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
      <div class="card-body">
        <h3 class="card-title text-primary mb-4">Personal Information</h3>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Username (Read-only) -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Username</span>
            </label>
            <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
              <%= user.username %>
            </div>
          </div>

          <!-- Full Name -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Full Name</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('fullName')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="fullName-display" class="input input-bordered flex items-center"><%= user.fullName %></div>
            <% if (isOwnProfile) { %>
            <input type="text" id="fullName-input" name="fullName" value="<%= user.fullName %>" class="input input-bordered hidden" required />
            <% } %>
          </div>

          <!-- Date of Birth -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Date of Birth</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('dateOfBirth')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="dateOfBirth-display" class="input input-bordered flex items-center"><%= dateDisplay %></div>
            <% if (isOwnProfile) { %>
            <input type="date" id="dateOfBirth-input" name="dateOfBirth" value="<%= dateInput %>" class="input input-bordered hidden" required />
            <% } %>
          </div>

          <!-- Gender -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Gender</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('gender')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="gender-display" class="input input-bordered flex items-center"><%= user.gender %></div>
            <% if (isOwnProfile) { %>
            <select id="gender-input" name="gender" class="select select-bordered hidden" required>
              <option value="MALE" <%= Gender.MALE.equals(user.gender) ? "selected" : "" %>>Male</option>
              <option value="FEMALE" <%= Gender.FEMALE.equals(user.gender) ? "selected" : "" %>>Female</option>
            </select>
            <% } %>
          </div>

          <!-- IC/Passport -->
          <div class="form-control lg:col-span-2">
            <label class="label">
              <span class="label-text font-semibold">IC/Passport Number</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('ic')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="ic-display" class="input input-bordered flex items-center"><%= user.ic %></div>
            <% if (isOwnProfile) { %>
            <input type="text" id="ic-input" name="ic" value="<%= user.ic %>" class="input input-bordered hidden" required />
            <% } %>
          </div>
        </div>
      </div>
    </div>

    <!-- Contact Information Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
      <div class="card-body">
        <h3 class="card-title text-primary mb-4">Contact Information</h3>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Email -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Email</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('email')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="email-display" class="input input-bordered flex items-center"><%= user.email %></div>
            <% if (isOwnProfile) { %>
            <input type="email" id="email-input" name="email" value="<%= user.email %>" class="input input-bordered hidden" required />
            <% } %>
          </div>

          <!-- Phone Number -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Phone Number</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('phoneNumber')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="phoneNumber-display" class="input input-bordered flex items-center"><%= user.phoneNumber %></div>
            <% if (isOwnProfile) { %>
            <input type="tel" id="phoneNumber-input" name="phoneNumber" value="<%= user.phoneNumber %>" class="input input-bordered hidden" pattern="[0-9]{10,11}" required />
            <% } %>
          </div>

          <!-- Address -->
          <div class="form-control lg:col-span-2">
            <label class="label">
              <span class="label-text font-semibold">Address</span>
              <% if (isOwnProfile) { %>
              <button type="button" class="btn btn-ghost btn-xs" onclick="toggleEdit('address')">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                </svg>
              </button>
              <% } %>
            </label>
            <div id="address-display" class="input input-bordered flex items-center min-h-[3rem]"><%= user.address %></div>
            <% if (isOwnProfile) { %>
            <textarea id="address-input" name="address" class="textarea textarea-bordered hidden" rows="3" required><%= user.address %></textarea>
            <% } %>
          </div>
        </div>
      </div>
    </div>

    <!-- Role Information Section -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
      <div class="card-body">
        <h3 class="card-title text-primary mb-4">Role Information</h3>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Role (Read-only) -->
          <div class="form-control">
            <label class="label">
              <span class="label-text font-semibold">Role</span>
            </label>
            <div class="input input-bordered flex items-center bg-base-200 cursor-not-allowed">
              <%= user.role %>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Action Buttons -->
    <% if (isOwnProfile) { %>
    <div class="flex justify-end gap-2">
      <button type="button" id="cancelBtn" class="btn btn-outline hidden" onclick="cancelEdit()">Cancel</button>
      <button type="submit" id="saveBtn" class="btn btn-primary text-white hidden">Save Changes</button>
    </div>
    <% } %>
  </form>

  <!-- Change Password Modal -->
  <% if (isOwnProfile) { %>
  <dialog id="change_password_modal" class="modal">
    <div class="modal-box">
      <form method="dialog">
        <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
      </form>
      <h3 class="text-lg font-bold">Change Password</h3>
      <p class="py-4 text-gray-500">Press ESC key or click on ✕ button to close</p>

      <form method="POST" action="<%= contextPath %>/users" class="space-y-4">
        <input type="hidden" name="_method" value="PUT" />
        <input type="hidden" name="userId" value="<%= user.userId %>" />
        <input type="hidden" name="username" value="<%= user.username %>" />
        <input type="hidden" name="role" value="<%= user.role %>" />
        <input type="hidden" name="fullName" value="<%= user.fullName %>" />
        <input type="hidden" name="dateOfBirth" value="<%= dateInput %>" />
        <input type="hidden" name="gender" value="<%= user.gender %>" />
        <input type="hidden" name="ic" value="<%= user.ic %>" />
        <input type="hidden" name="email" value="<%= user.email %>" />
        <input type="hidden" name="phoneNumber" value="<%= user.phoneNumber %>" />
        <input type="hidden" name="address" value="<%= user.address %>" />

        <fieldset class="fieldset">
          <legend class="fieldset-legend">New Password *</legend>
          <input type="password"
                 id="newPassword"
                 name="password"
                 class="input input-bordered w-full"
                 placeholder="Enter new password"
                 required
                 minlength="8" />
          <label class="label">
            <span class="label-text-alt text-gray-500">Minimum 8 characters</span>
          </label>
        </fieldset>

        <fieldset class="fieldset">
          <legend class="fieldset-legend">Confirm New Password *</legend>
          <input type="password"
                 id="confirmPassword"
                 class="input input-bordered w-full"
                 placeholder="Re-enter new password"
                 required
                 minlength="8" />
        </fieldset>

        <div class="modal-action">
          <button type="button" onclick="change_password_modal.close()" class="btn btn-outline">Cancel</button>
          <button type="submit" class="btn btn-primary">Change Password</button>
        </div>
      </form>
    </div>
  </dialog>
  <% } %>
</div>

<% if (isOwnProfile) { %>
<script>
  let editingFields = new Set();
  let originalValues = {};

  function toggleEdit(fieldName) {
    const display = document.getElementById(fieldName + '-display');
    const input = document.getElementById(fieldName + '-input');

    if (display.classList.contains('hidden')) {
      // Cancel editing this field
      display.classList.remove('hidden');
      input.classList.add('hidden');
      editingFields.delete(fieldName);
    } else {
      // Store original value
      if (!originalValues[fieldName]) {
        if (input.tagName === 'SELECT') {
          originalValues[fieldName] = input.value;
        } else if (input.tagName === 'TEXTAREA') {
          originalValues[fieldName] = input.value;
        } else {
          originalValues[fieldName] = input.value;
        }
      }

      // Start editing this field
      display.classList.add('hidden');
      input.classList.remove('hidden');
      input.focus();
      editingFields.add(fieldName);
    }

    updateActionButtons();
  }

  function updateActionButtons() {
    const saveBtn = document.getElementById('saveBtn');
    const cancelBtn = document.getElementById('cancelBtn');

    if (editingFields.size > 0) {
      saveBtn.classList.remove('hidden');
      cancelBtn.classList.remove('hidden');
    } else {
      saveBtn.classList.add('hidden');
      cancelBtn.classList.add('hidden');
    }
  }

  function cancelEdit() {
    editingFields.forEach(fieldName => {
      const display = document.getElementById(fieldName + '-display');
      const input = document.getElementById(fieldName + '-input');

      // Reset input to original value
      if (originalValues[fieldName]) {
        input.value = originalValues[fieldName];
      }

      // Show display, hide input
      display.classList.remove('hidden');
      input.classList.add('hidden');
    });

    editingFields.clear();
    originalValues = {};
    updateActionButtons();
  }

  // Validate password confirmation
  document.querySelector('#change_password_modal form').addEventListener('submit', function(e) {
    const newPassword = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    if (newPassword !== confirmPassword) {
      e.preventDefault();
      alert('New password and confirmation do not match!');
    }
  });
</script>
<% } %>
