# EPDA LMS - Project Documentation

## 2. Architecture Overview

### 2.1 Web Components

#### 2.1.1 Overview of Web Components

The EPDA Learning Management System (LMS) implements a component-based architecture using JavaServer Pages (JSP) to create a modular and maintainable web application. This architecture separates concerns between presentation logic and business logic, enabling better code organization and reusability.

##### Component Structure

The web components are organized in a hierarchical structure under `/src/main/webapp/WEB-INF/components/` directory, following a role-based organization pattern:

```
WEB-INF/components/
├── admin/                  # Administrator-specific components
│   ├── classes.jsp
│   ├── dashboard.jsp
│   ├── grading.jsp
│   ├── lecturer-assignment.jsp
│   ├── modules.jsp
│   ├── profile.jsp
│   ├── reports.jsp
│   ├── settings.jsp
│   └── users.jsp
├── academic leader/        # Academic Leader-specific components
│   ├── assign.jsp
│   ├── dashboard.jsp
│   ├── modules.jsp
│   ├── profile.jsp
│   └── settings.jsp
├── lecturer/               # Lecturer-specific components
│   ├── classes.jsp
│   ├── dashboard.jsp
│   ├── profile.jsp
│   └── settings.jsp
├── student/                # Student-specific components
│   ├── assignments.jsp
│   ├── calendar.jsp
│   ├── dashboard.jsp
│   ├── profile.jsp
│   ├── results.jsp
│   └── settings.jsp
├── dashboard.jsp           # Shared dashboard component
├── modal-message.jsp       # Shared modal message component
├── profile.jsp             # Shared profile component
└── settings.jsp            # Shared settings component
```

##### Component Types

**1. Role-Based Components**

Components are organized by user roles (Admin, Academic Leader, Lecturer, Student), providing role-specific functionality:

- **Admin Components**: Manage users, classes, lecturers, grading systems, and reports
- **Academic Leader Components**: Manage modules and assign lecturers to courses
- **Lecturer Components**: Manage classes and view teaching assignments
- **Student Components**: Access assignments, calendar, results, and course materials

**2. Shared Components**

Common components used across multiple roles:

- `dashboard.jsp`: Role-agnostic dashboard template
- `profile.jsp`: User profile management
- `settings.jsp`: User settings and preferences
- `modal-message.jsp`: Alert and notification system

**3. View Fragments**

Additional view fragments are stored in `/src/main/webapp/WEB-INF/views/` for more granular UI components:

```
WEB-INF/views/
├── academic-leader/
│   ├── modules-form-fragment.jsp
│   └── modules-table-fragment.jsp
├── admin/
│   ├── class-details-fragment.jsp
│   ├── classes-academic-leader-dropdown-fragment.jsp
│   ├── classes-fragment.jsp
│   ├── grading-fragment.jsp
│   ├── lecturer-assignment-fragment.jsp
│   └── user-table-fragment.jsp
├── common/
│   └── profile-fragment.jsp
└── lecturer/
    ├── assessment-details.jsp
    ├── class-details.jsp
    └── class-list-fragment.jsp
```

##### Component Integration

Components are dynamically loaded using JSP include directives based on the user's role and requested page. The main entry point (`index.jsp`) uses the following pattern:

```jsp
<c:set var="role" value="<%= UserRole.roleToString(role).toLowerCase() %>"/>
<c:set var="pageToInclude" value="/WEB-INF/components/${role}/${
     param.page != null ? param.page : 'dashboard'
}.jsp"/>
<jsp:include page="${pageToInclude}"/>
```

This allows for:
- **Dynamic routing**: Components are loaded based on URL parameters
- **Role-based access control**: Only authorized components are accessible to each role
- **Component isolation**: Each role has its own component namespace

##### Security Features

All components implement security measures:

1. **Authentication Check**: Components verify if the user session is authenticated
2. **Include-Only Access**: Components check if they're being included (not directly accessed)
3. **Session Validation**: User credentials and roles are validated before rendering

Example from component security implementation:
```jsp
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
%>
```

##### Component Communication

Components communicate through:

1. **Request Attributes**: Data passed between servlets and JSP pages
2. **Session Attributes**: User-specific data maintained across requests
3. **URL Parameters**: Page navigation and component selection
4. **Modal Messages**: Feedback system using `modal-message.jsp` for success/error notifications

##### Technology Stack

The web components utilize:
- **Jakarta Servlet API 6.1.0**: Server-side request handling
- **Jakarta Server Pages (JSP)**: Template rendering
- **JSTL 3.0.0**: Tag library for common operations
- **DaisyUI 5**: CSS component library
- **Tailwind CSS 4**: Utility-first CSS framework
- **Cally**: Web component for calendar functionality

##### Benefits of This Architecture

1. **Modularity**: Each component is self-contained and can be developed independently
2. **Reusability**: Shared components reduce code duplication
3. **Maintainability**: Clear separation of concerns makes updates easier
4. **Scalability**: New roles or features can be added without affecting existing components
5. **Security**: Centralized security checks in each component
6. **Testability**: Components can be tested in isolation

This component-based architecture provides a solid foundation for the LMS, enabling efficient development and maintenance while ensuring security and scalability.
