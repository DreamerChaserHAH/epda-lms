<%--
  Student Notifications Component
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Long userId = (Long) session.getAttribute("userId");
%>
<div class="dropdown dropdown-end">
    <div tabindex="0" role="button" class="btn btn-ghost btn-circle">
        <div class="indicator">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <span class="badge badge-xs badge-primary indicator-item" id="notificationBadge" style="display:none;">0</span>
        </div>
    </div>
    <ul tabindex="0" class="dropdown-content menu bg-base-100 rounded-box z-[1] w-96 shadow-lg border border-gray-200 mt-2 max-h-96 overflow-y-auto">
        <li class="menu-title p-2">
            <span>Notifications</span>
            <button onclick="markAllAsRead()" class="btn btn-xs btn-ghost">Mark all as read</button>
        </li>
        <div id="notificationsList">
            <li class="p-4 text-center">
                <span class="loading loading-spinner loading-sm"></span>
                <span class="ml-2">Loading...</span>
            </li>
        </div>
        <li class="p-2 text-center">
            <a href="?page=notifications" class="btn btn-sm btn-ghost w-full">View All</a>
        </li>
    </ul>
</div>

<script>
    const notificationApi = '<%= request.getContextPath() %>/api/notifications';
    const userId = <%= userId != null ? userId : 0 %>;

    function loadNotifications() {
        fetch(notificationApi + '?unreadOnly=true')
            .then(response => response.json())
            .then(data => {
                updateNotificationBadge(data.length);
                renderNotifications(data.slice(0, 5)); // Show only 5 most recent
            })
            .catch(error => {
                console.error('Error loading notifications:', error);
            });
    }

    function updateNotificationBadge(count) {
        const badge = document.getElementById('notificationBadge');
        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.style.display = 'block';
        } else {
            badge.style.display = 'none';
        }
    }

    function renderNotifications(notifications) {
        const list = document.getElementById('notificationsList');
        if (notifications.length === 0) {
            list.innerHTML = '<li class="p-4 text-center text-gray-500">No new notifications</li>';
            return;
        }

        list.innerHTML = notifications.map(function(n) {
            const typeIcon = n.type === 'NEW_ASSIGNMENT' ? '📝' :
                           n.type === 'GRADE_POSTED' ? '✅' :
                           n.type === 'DEADLINE_REMINDER' ? '⏰' :
                           n.type === 'ANNOUNCEMENT' ? '📢' : '🔔';
            const typeColor = n.type === 'NEW_ASSIGNMENT' ? 'badge-info' :
                            n.type === 'GRADE_POSTED' ? 'badge-success' :
                            n.type === 'DEADLINE_REMINDER' ? 'badge-warning' :
                            n.type === 'ANNOUNCEMENT' ? 'badge-primary' : 'badge-secondary';
            
            return '<li class="' + (n.isRead ? '' : 'bg-blue-50') + '">' +
                '<a onclick="markAsRead(' + n.id + ')" class="p-3 hover:bg-base-200">' +
                    '<div class="flex items-start gap-3">' +
                        '<span class="text-2xl">' + typeIcon + '</span>' +
                        '<div class="flex-1">' +
                            '<div class="flex items-center gap-2 mb-1">' +
                                '<span class="font-semibold text-sm">' + escapeHtml(n.title) + '</span>' +
                                '<span class="badge badge-xs ' + typeColor + '">' + n.type.replace('_', ' ') + '</span>' +
                            '</div>' +
                            '<p class="text-xs text-gray-600">' + escapeHtml(n.message) + '</p>' +
                            '<p class="text-xs text-gray-400 mt-1">' + formatDate(n.createdAt) + '</p>' +
                        '</div>' +
                    '</div>' +
                '</a>' +
            '</li>';
        }).join('');
    }

    function markAsRead(notificationId) {
        fetch(notificationApi + '/' + notificationId + '?_method=PUT', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'isRead=true'
        })
        .then(() => {
            loadNotifications();
        })
        .catch(error => console.error('Error marking notification as read:', error));
    }

    function markAllAsRead() {
        fetch(notificationApi)
            .then(response => response.json())
            .then(notifications => {
                const unread = notifications.filter(n => !n.isRead);
                Promise.all(unread.map(n => 
                    fetch(notificationApi + '/' + n.id + '?_method=PUT', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: 'isRead=true'
                    })
                )).then(() => loadNotifications());
            });
    }

    function formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const now = new Date();
        const diff = now - date;
        const minutes = Math.floor(diff / 60000);
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);
        
        if (minutes < 1) return 'Just now';
        if (minutes < 60) return minutes + 'm ago';
        if (hours < 24) return hours + 'h ago';
        if (days < 7) return days + 'd ago';
        return date.toLocaleDateString();
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Load notifications on page load and refresh every 30 seconds
    document.addEventListener('DOMContentLoaded', function() {
        loadNotifications();
        setInterval(loadNotifications, 30000);
    });
</script>

