<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.models.Grading" %>
<%@ page import="java.util.List" %>
<%
    List<Grading> gradings = (List<Grading>) request.getAttribute("gradings");
%>
<div class="overflow-x-auto w-full pt-4">
    <table class="table table-s table-pin-rows table-pin-cols">
        <thead>
        <tr>
            <th>ID</th>
            <td>Grade Symbol</td>
            <td>Min Score</td>
            <td>Max Score</td>
            <td></td>
        </tr>
        </thead>
        <tbody>
        <% if (gradings != null) {
            for (Grading grading : gradings) { %>
        <tr>
            <th><%= grading.getGradingId() %></th>
            <td><%= grading.getGradeSymbol() %></td>
            <td><%= grading.getMinScore() %></td>
            <td><%= grading.getMaxScore() %></td>
            <td>
                <div class="flex gap-2">
                    <button class="btn btn-sm btn-outline"
                            onclick="showEditModal(
                                    '<%= grading.getGradingId() %>',
                                    '<%= grading.getGradeSymbol() %>',
                                <%= grading.getMinScore() %>,
                                <%= grading.getMaxScore() %>)">
                        Edit
                    </button>
                    <button class="btn btn-sm btn-error btn-outline"
                            onclick="showDeleteModal('<%= grading.getGradingId() %>', '<%= grading.getGradeSymbol() %>')">
                        Delete
                    </button>
                </div>
            </td>
        </tr>
        <% }
        } %>
        </tbody>
    </table>

    <dialog id="edit_grading_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Edit Grading</h3>

            <form id="editGradingForm" class="py-4 space-y-4">
                <input type="hidden" id="editGradingId" name="gradingId" />

                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Grade Symbol *</span>
                    </label>
                    <input type="text" id="editGradeSymbol" name="gradeSymbol" class="input input-bordered w-full" required />
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Min Score *</span>
                    </label>
                    <input type="number" id="editMinScore" name="minScore" class="input input-bordered w-full" min="0" max="100" required />
                </div>

                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Max Score *</span>
                    </label>
                    <input type="number" id="editMaxScore" name="maxScore" class="input input-bordered w-full" min="0" max="100" required />
                </div>

                <div class="modal-action">
                    <button type="button" onclick="edit_grading_modal.close()" class="btn btn-outline">Cancel</button>
                    <button type="button" id="confirmEditBtn" class="btn btn-primary">Update Grading</button>
                </div>
            </form>
        </div>
    </dialog>

    <dialog id="delete_grading_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Delete Grading</h3>
            <p class="py-4">Are you sure you want to delete grading rule <strong id="deleteGradeSymbol"></strong>?</p>

            <input type="hidden" id="deleteGradingId" />

            <div class="modal-action">
                <button type="button" onclick="delete_grading_modal.close()" class="btn btn-outline">Cancel</button>
                <button type="button" id="confirmDeleteBtn" class="btn btn-error">Delete</button>
            </div>
        </div>
    </dialog>

    <script>
        function showEditModal(gradingId, gradeSymbol, minScore, maxScore) {
            document.getElementById('editGradingId').value = gradingId;
            document.getElementById('editGradeSymbol').value = gradeSymbol;
            document.getElementById('editMinScore').value = minScore;
            document.getElementById('editMaxScore').value = maxScore;
            edit_grading_modal.showModal();
        }

        function showDeleteModal(gradingId, gradeSymbol) {
            document.getElementById('deleteGradingId').value = gradingId;
            document.getElementById('deleteGradeSymbol').textContent = gradeSymbol;
            delete_grading_modal.showModal();
        }

        document.getElementById('confirmEditBtn').addEventListener('click', async function() {
            const gradingId = document.getElementById('editGradingId').value;
            const gradeSymbol = document.getElementById('editGradeSymbol').value;
            const minScore = document.getElementById('editMinScore').value;
            const maxScore = document.getElementById('editMaxScore').value;

            if (parseInt(minScore) > parseInt(maxScore)) {
                alert('Min Score cannot be greater than Max Score');
                return;
            }

            try {
                const response = await fetch('<%= request.getContextPath() %>/gradings', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({
                        gradingId: gradingId,
                        gradeSymbol: gradeSymbol,
                        minScore: minScore,
                        maxScore: maxScore
                    })
                });

                if (response.ok) {
                    window.location.reload();
                } else {
                    alert('Failed to update grading');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('Error updating grading');
            }
        });

        document.getElementById('confirmDeleteBtn').addEventListener('click', async function() {
            const gradingId = document.getElementById('deleteGradingId').value;

            try {
                const response = await fetch('<%= request.getContextPath() %>/gradings', {
                    method: 'DELETE',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams({
                        gradingId: gradingId
                    })
                });

                if (response.ok) {
                    window.location.reload();
                } else {
                    alert('Failed to delete grading');
                }
            } catch (error) {
                console.error('Error:', error);
                alert('Error deleting grading');
            }
        });
    </script>
</div>
