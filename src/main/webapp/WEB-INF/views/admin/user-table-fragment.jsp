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
                <button class="btn btn-outline btn-error">
                    Delete
                </button>
            </td>
            <th><%= user.userId %></th>
        </tr>
        <% }
        } %>
        </tbody>
    </table>
</div>
