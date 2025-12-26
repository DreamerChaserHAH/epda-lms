<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.ClassDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="com.htetaung.lms.models.dto.ModuleDTO" %>
<%@ page import="java.util.HashMap" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    if (
            request.getAttribute("modules") == null ||
                    request.getAttribute("moduleClassesMap") == null
    ) {
        request.setAttribute("includingPage", "/WEB-INF/views/admin/classes-fragment.jsp");
        request.getRequestDispatcher("/classes").include(request, response);
        return;
    }

    List<ModuleDTO> moduleDTOs = (List<ModuleDTO>) request.getAttribute("modules");
    HashMap<ModuleDTO, List<ClassDTO>> moduleClassesMap = (HashMap<ModuleDTO, List<ClassDTO>>) request.getAttribute("moduleClassesMap");
    String contextPath = request.getContextPath();
%>

<% if (moduleDTOs == null || moduleDTOs.isEmpty()) { %>
<div class="alert alert-warning">
    <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
    </svg>
    <span>There are no modules within the system</span>
</div>
<% } else { %>
<div class="space-y-8">
    <% for (ModuleDTO module : moduleDTOs) {
        List<ClassDTO> classes = moduleClassesMap.get(module);
        String modalId = "createClassModal_" + module.moduleId;
    %>
    <div class="card bg-base-100 shadow-lg border border-base-300 hover:shadow-xl transition-shadow duration-300">
        <div class="card-body">
            <!-- Module Header with Create Class Button -->
            <div class="flex justify-between items-center mb-6">
                <div class="flex items-center gap-3">
                    <h2 class="text-2xl font-bold text-base-content">
                        <%= module.moduleName %>
                    </h2>
                    <div class="badge badge-primary badge-lg font-semibold">
                        <%= classes != null ? classes.size() : 0 %> Classes
                    </div>
                </div>
                <button type="button"
                        class="btn btn-primary text-white font-semibold px-6 py-2 rounded-lg hover:scale-105 transition-transform duration-200"
                        onclick="<%= modalId %>.showModal()">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Create Class
                </button>
            </div>

            <!-- Horizontally Scrollable Classes -->
            <div class="overflow-x-auto pb-4 -mx-2 px-2">
                <div class="flex gap-6 min-w-max">
                    <% if (classes != null && !classes.isEmpty()) {
                        for (ClassDTO classDTO : classes) {
                    %>
                    <div class="card bg-gradient-to-br from-base-200 to-base-300 shadow-lg hover:shadow-xl w-80 flex-shrink-0 border border-base-300 transition-all duration-300 hover:scale-105">
                        <div class="card-body p-6">
                            <h3 class="card-title text-xl font-bold text-base-content mb-4">
                                <%= classDTO.className %>
                            </h3>
                            <div class="space-y-3">
                                <% if (classDTO.moduleDTO.managedBy != null) { %>
                                <div class="flex items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                    </svg>
                                    <p class="text-sm">
                                        <span class="font-semibold text-base-content">Lecturer:</span>
                                        <span class="text-base-content/80"><%= classDTO.moduleDTO.managedBy.fullname %></span>
                                    </p>
                                </div>
                                <% } %>
                            </div>
                            <div class="card-actions justify-end mt-6">
                                <button class="btn btn-primary btn-sm text-white font-semibold rounded-lg hover:scale-105 transition-transform"
                                        onclick="window.location.href='<%= contextPath %>/index.jsp?page=classes&classId=<%= classDTO.classId %>'">
                                    View Details
                                </button>
                            </div>
                        </div>
                    </div>
                    <% }
                    } else { %>
                    <div class="alert alert-info shadow-md">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span class="font-medium">No classes found for this module</span>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <!-- Create Class Modal for this module -->
    <dialog id="<%= modalId %>" class="modal">
        <div class="modal-box max-w-md">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="font-bold text-2xl mb-6 text-base-content">Create New Class</h3>
            <form method="POST" action="<%= contextPath %>/classes">
                <input type="hidden" name="moduleId" value="<%= module.moduleId %>">
                <input type="hidden" name="leaderId" value="<%= request.getParameter("leaderId") != null ? request.getParameter("leaderId") : "" %>">

                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold text-base-content">Class Name</span>
                    </label>
                    <input type="text" name="className" class="input input-bordered w-full focus:input-primary" placeholder="Enter class name" required>
                </div>

                <div class="modal-action mt-6">
                    <button type="button" class="btn btn-ghost font-semibold" onclick="<%= modalId %>.close()">Cancel</button>
                    <button type="submit" class="btn btn-primary text-white font-semibold px-6 rounded-lg hover:scale-105 transition-transform">
                        Create Class
                    </button>
                </div>
            </form>
        </div>
        <form method="dialog" class="modal-backdrop">
            <button>close</button>
        </form>
    </dialog>
    <% } %>
</div>
<% } %>
