<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.dto.ModuleDTO" %>
<%@ page import="com.htetaung.lms.models.dto.LecturerDTO" %>
<%@ page import="java.util.List" %>
<%
    List<ModuleDTO> modules = (List<ModuleDTO>) request.getAttribute("modules");
    List<LecturerDTO> lecturers = (List<LecturerDTO>) request.getAttribute("lecturers");
%>
<div class="overflow-x-auto w-full pt-4">
    <table class="table table-s table-pin-rows table-pin-cols">
        <thead>
        <tr>
            <th>Module ID</th>
            <td>Module Name</td>
            <td>Managed By (Lecturer)</td>
            <td></td>
        </tr>
        </thead>
        <tbody>
        <% if (modules != null) {
            for (ModuleDTO module : modules) { %>
        <tr>
            <th><%= module.moduleId %></th>
            <td><%= module.moduleName %></td>
            <td>
                <form id="assignmentForm_<%= module.moduleId %>" method="POST" action="<%= request.getContextPath() %>/modules">
                    <input type="hidden" name="_method" value="PUT" />
                    <input type="hidden" name="moduleId" value="<%= module.moduleId %>" />
                    <input type="hidden" name="moduleName" value="<%= module.moduleName %>" />
                    <select class="select select-bordered w-full"
                            name="lecturerId"
                            id="lecturer_<%= module.moduleId %>"
                            data-original="<%= module.managedBy != null ? module.managedBy.fullname : "" %>"
                            onchange="enableSaveButton(<%= module.moduleId %>)">
                        <option value="">Not Assigned</option>
                        <% if (lecturers != null) {
                            for (LecturerDTO lecturer : lecturers) { %>
                        <option value="<%= lecturer.userId %>"
                                <%= (module.managedBy != null && module.managedBy.userId.equals(lecturer.userId)) ? "selected" : "" %>>
                            <%= lecturer.fullname %>
                        </option>
                        <% }
                        } %>
                    </select>
                </form>
            </td>
            <td>
                <div class="flex gap-2">
                    <button type="button" class="btn btn-sm btn-primary"
                            id="saveBtn_<%= module.moduleId %>"
                            onclick="saveAssignment(<%= module.moduleId %>)"
                            disabled>
                        Save
                    </button>
                    <button class="btn btn-sm btn-error btn-outline"
                            onclick="showDeleteModal(<%= module.moduleId %>, '<%= module.moduleName %>')">
                        Delete
                    </button>
                </div>
            </td>
        </tr>
        <% }
        } %>
        </tbody>
    </table>

    <dialog id="delete_module_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Delete Module</h3>
            <p class="py-4">Are you sure you want to delete module <strong id="deleteModuleName"></strong>?</p>

            <div class="modal-action">
                <form method="POST" action="<%= request.getContextPath() %>/modules" class="flex gap-2">
                    <input type="hidden" name="_method" value="DELETE" />
                    <input type="hidden" id="deleteModuleId" name="moduleId" />
                    <button type="button" onclick="delete_module_modal.close()" class="btn btn-outline">Cancel</button>
                    <button type="submit" class="btn btn-error">Delete</button>
                </form>
            </div>
        </div>
    </dialog>

    <script>
        function enableSaveButton(moduleId) {
            const select = document.getElementById('lecturer_' + moduleId);
            const saveBtn = document.getElementById('saveBtn_' + moduleId);
            const originalValue = select.getAttribute('data-original');

            if (select.value !== originalValue) {
                saveBtn.disabled = false;
                saveBtn.classList.remove('btn-disabled');
            } else {
                saveBtn.disabled = true;
                saveBtn.classList.add('btn-disabled');
            }
        }

        function saveAssignment(moduleId) {
            const form = document.getElementById('assignmentForm_' + moduleId);
            form.submit();
        }

        function showDeleteModal(moduleId, moduleName) {
            document.getElementById('deleteModuleId').value = moduleId;
            document.getElementById('deleteModuleName').textContent = moduleName;
            delete_module_modal.showModal();
        }
    </script>
</div>
