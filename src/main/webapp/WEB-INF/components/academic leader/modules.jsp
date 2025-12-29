<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
%>
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Modules System</h2>
        <button type="button"
                class="btn btn-primary text-white font-semibold px-4 py-2 rounded-lg transition-colors"
                onclick="create_module_modal.showModal()">
            Create Module
        </button>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">Manage the modules</p>

    <jsp:include page="../../views/academic-leader/modules-form-fragment.jsp"/>
    <jsp:include page="../../views/academic-leader/modules-table-fragment.jsp"/>

</div>
