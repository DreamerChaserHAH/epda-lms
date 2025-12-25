<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String contextPath = request.getContextPath();
%>
<div>
    <div class="flex items-center justify-between pb-3 pt-3">
        <h2 class="font-title font-bold text-2xl">Grading System</h2>
        <button type="button"
                class="btn btn-primary text-white font-semibold px-4 py-2 rounded-lg transition-colors"
                onclick="add_grading_modal.showModal()"
        >
            Add Grading Rule
        </button>
    </div>
    <p class="text-lg text-gray-500 pr-6 pt-2">Design the Grading System to be used System Wide</p>

    <dialog id="add_grading_modal" class="modal">
        <div class="modal-box">
            <form method="dialog">
                <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">✕</button>
            </form>
            <h3 class="text-lg font-bold">Add Grading Rule</h3>
            <p class="py-4 text-gray-500">Press ESC key or click on ✕ button to close</p>

            <form method="post" action="<%= contextPath %>/gradings" class="space-y-6">
                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Grade Symbol *</legend>
                    <input type="text" name="gradeSymbol" class="input input-bordered w-full" placeholder="e.g., A+, A, B+" required />
                </fieldset>

                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Min Score *</legend>
                    <input type="number" name="minScore" class="input input-bordered w-full" placeholder="Enter minimum score" min="0" max="100" required />
                </fieldset>

                <fieldset class="fieldset">
                    <legend class="fieldset-legend">Max Score *</legend>
                    <input type="number" name="maxScore" class="input input-bordered w-full" placeholder="Enter maximum score" min="0" max="100" required />
                </fieldset>

                <div class="form-control mt-8">
                    <button type="submit" class="btn btn-primary text-white w-full">Add Grading Rule</button>
                </div>
            </form>
        </div>
    </dialog>

    <jsp:include page="/gradings"/>
</div>
