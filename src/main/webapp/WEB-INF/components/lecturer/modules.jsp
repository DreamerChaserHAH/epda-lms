<%--
  Assessment Management Interface for Lecturers
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

    String username = (String) session.getAttribute("username");
    String role = session.getAttribute("role") != null ?
            session.getAttribute("role").toString() : "LECTURER";
%>
<div class="p-6">
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">Assessment Management</h1>
        <p class="text-gray-600">Manage your assessments and assignments</p>
    </div>

    <!-- Action Bar -->
    <div class="flex flex-wrap gap-4 mb-6 items-center justify-between">
        <div class="flex flex-wrap gap-4 items-center">
            <!-- Search by Name -->
            <div class="form-control">
                <input type="text" id="searchName" placeholder="Search by name..." 
                       class="input input-bordered w-64" />
            </div>
            
            <!-- Filter by Visibility -->
            <select id="filterVisibility" class="select select-bordered">
                <option value="">All Visibility</option>
                <option value="PUBLIC">Public</option>
                <option value="PRIVATE">Private</option>
                <option value="RESTRICTED">Restricted</option>
            </select>
            
            <!-- Filter by Assessment Type -->
            <select id="filterAssessmentType" class="select select-bordered">
                <option value="">All Types</option>
                <option value="QUIZ">Quiz</option>
                <option value="ASSIGNMENT">Assignment</option>
                <option value="EXAM">Exam</option>
                <option value="PROJECT">Project</option>
                <option value="PRESENTATION">Presentation</option>
            </select>
            
            <!-- Filter by Deadline -->
            <input type="date" id="filterDeadline" class="input input-bordered" />
            
            <button onclick="applyFilters()" class="btn btn-primary">Apply Filters</button>
            <button onclick="clearFilters()" class="btn btn-ghost">Clear</button>
        </div>
        
        <button onclick="showCreateModal()" class="btn btn-primary">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            Create Assessment
        </button>
    </div>

    <!-- Assessments Table -->
    <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
            <div class="overflow-x-auto">
                <table class="table table-zebra w-full">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Description</th>
                            <th>Type</th>
                            <th>Visibility</th>
                            <th>Deadline</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="assessmentsTableBody">
                        <tr>
                            <td colspan="8" class="text-center">
                                <span class="loading loading-spinner loading-lg"></span>
                                <p class="mt-2">Loading assessments...</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Create/Edit Assessment Modal -->
<div id="assessmentModal" class="modal">
    <div class="modal-box w-11/12 max-w-3xl">
        <h3 class="font-bold text-lg mb-4" id="modalTitle">Create Assessment</h3>
        
        <form id="assessmentForm" onsubmit="saveAssessment(event)">
            <input type="hidden" id="assessmentId" />
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Assessment Name *</span>
                </label>
                <input type="text" id="assessmentName" placeholder="Enter assessment name" 
                       class="input input-bordered" required />
            </div>
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Description</span>
                </label>
                <textarea id="assessmentDescription" placeholder="Enter description" 
                          class="textarea textarea-bordered" rows="3"></textarea>
            </div>
            
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Assessment Type *</span>
                    </label>
                    <select id="assessmentType" class="select select-bordered" required>
                        <option value="">Select type</option>
                        <option value="QUIZ">Quiz</option>
                        <option value="ASSIGNMENT">Assignment</option>
                        <option value="EXAM">Exam</option>
                        <option value="PROJECT">Project</option>
                        <option value="PRESENTATION">Presentation</option>
                    </select>
                </div>
                
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Visibility *</span>
                    </label>
                    <select id="assessmentVisibility" class="select select-bordered" required>
                        <option value="">Select visibility</option>
                        <option value="PUBLIC">Public</option>
                        <option value="PRIVATE">Private</option>
                        <option value="RESTRICTED">Restricted</option>
                    </select>
                </div>
            </div>
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Deadline *</span>
                </label>
                <input type="datetime-local" id="assessmentDeadline" 
                       class="input input-bordered" required />
            </div>
            
            <div class="modal-action">
                <button type="button" onclick="closeModal()" class="btn btn-ghost">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Assessment</button>
            </div>
        </form>
    </div>
    <div class="modal-backdrop" onclick="closeModal()"></div>
</div>

<!-- Quiz Questions Management Modal -->
<div id="quizQuestionsModal" class="modal">
    <div class="modal-box w-11/12 max-w-5xl">
        <h3 class="font-bold text-lg mb-4" id="quizQuestionsModalTitle">Manage Quiz Questions</h3>
        
        <div class="mb-4">
            <button onclick="showAddQuestionModal()" class="btn btn-primary btn-sm">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Add Question
            </button>
        </div>
        
        <div id="quizQuestionsList" class="space-y-3 max-h-96 overflow-y-auto">
            <!-- Questions will be loaded here -->
        </div>
        
        <div class="modal-action">
            <button onclick="closeQuizQuestionsModal()" class="btn btn-primary">Close</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeQuizQuestionsModal()"></div>
</div>

<!-- Add/Edit Question Modal -->
<div id="questionModal" class="modal">
    <div class="modal-box w-11/12 max-w-3xl">
        <h3 class="font-bold text-lg mb-4" id="questionModalTitle">Add Question</h3>
        
        <form id="questionForm" onsubmit="saveQuestion(event)">
            <input type="hidden" id="questionId" />
            <input type="hidden" id="questionAssessmentId" />
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Question Text *</span>
                </label>
                <textarea id="questionText" placeholder="Enter question" 
                          class="textarea textarea-bordered" rows="3" required></textarea>
            </div>
            
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Option A *</span>
                    </label>
                    <input type="text" id="optionA" class="input input-bordered" required />
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Option B *</span>
                    </label>
                    <input type="text" id="optionB" class="input input-bordered" required />
                </div>
            </div>
            
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Option C (Optional)</span>
                    </label>
                    <input type="text" id="optionC" class="input input-bordered" />
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text">Option D (Optional)</span>
                    </label>
                    <input type="text" id="optionD" class="input input-bordered" />
                </div>
            </div>
            
            <div class="grid grid-cols-2 gap-4 mb-4">
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Correct Answer *</span>
                    </label>
                    <select id="correctAnswer" class="select select-bordered" required>
                        <option value="">Select answer</option>
                        <option value="A">A</option>
                        <option value="B">B</option>
                        <option value="C">C</option>
                        <option value="D">D</option>
                    </select>
                </div>
                <div class="form-control">
                    <label class="label">
                        <span class="label-text font-semibold">Points *</span>
                    </label>
                    <input type="number" id="questionPoints" class="input input-bordered" value="1" min="1" required />
                </div>
            </div>
            
            <div class="modal-action">
                <button type="button" onclick="closeQuestionModal()" class="btn btn-ghost">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Question</button>
            </div>
        </form>
    </div>
    <div class="modal-backdrop" onclick="closeQuestionModal()"></div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="modal">
    <div class="modal-box">
        <h3 class="font-bold text-lg">Confirm Delete</h3>
        <p class="py-4">Are you sure you want to delete this assessment? This action cannot be undone.</p>
        <div class="modal-action">
            <button onclick="closeDeleteModal()" class="btn btn-ghost">Cancel</button>
            <button onclick="confirmDelete()" class="btn btn-error">Delete</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeDeleteModal()"></div>
</div>

<script>
    let assessments = [];
    let deleteAssessmentId = null;
    const apiBase = '<%= request.getContextPath() %>/api/assessments';

    // Load assessments on page load
    document.addEventListener('DOMContentLoaded', function() {
        loadAssessments();
    });

    // Load all assessments
    async function loadAssessments() {
        try {
            const response = await fetch(apiBase);
            if (!response.ok) throw new Error('Failed to load assessments');
            
            assessments = await response.json();
            renderAssessments(assessments);
        } catch (error) {
            console.error('Error loading assessments:', error);
            document.getElementById('assessmentsTableBody').innerHTML = 
                '<tr><td colspan="8" class="text-center text-error">Error loading assessments</td></tr>';
        }
    }

    // Render assessments table
    function renderAssessments(data) {
        const tbody = document.getElementById('assessmentsTableBody');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center">No assessments found</td></tr>';
            return;
        }
        
        tbody.innerHTML = data.map(function(assessment) {
            const name = escapeHtml(assessment.name);
            const description = escapeHtml(assessment.description || '-');
            const type = assessment.assessmentType;
            const visibility = assessment.visibility;
            const deadline = formatDate(assessment.deadline);
            const createdAt = formatDate(assessment.createdAt);
            const id = assessment.id;
            
            return '<tr>' +
                '<td>' + id + '</td>' +
                '<td class="font-semibold">' + name + '</td>' +
                '<td>' + description + '</td>' +
                '<td><span class="badge badge-info">' + type + '</span></td>' +
                '<td><span class="badge badge-secondary">' + visibility + '</span></td>' +
                '<td>' + deadline + '</td>' +
                '<td>' + createdAt + '</td>' +
                    '<td>' +
                        '<div class="flex gap-2">' +
                            (type === 'QUIZ' ? 
                                '<button onclick="manageQuizQuestions(' + id + ')" class="btn btn-sm btn-info">Manage Questions</button>' : '') +
                            '<button onclick="editAssessment(' + id + ')" class="btn btn-sm btn-primary">Edit</button>' +
                            '<button onclick="showDeleteModal(' + id + ')" class="btn btn-sm btn-error">Delete</button>' +
                        '</div>' +
                    '</td>' +
            '</tr>';
        }).join('');
    }

    // Apply filters
    async function applyFilters() {
        const name = document.getElementById('searchName').value.trim();
        const visibility = document.getElementById('filterVisibility').value;
        const assessmentType = document.getElementById('filterAssessmentType').value;
        const deadline = document.getElementById('filterDeadline').value;
        
        let filtered = [...assessments];
        
        // Filter by name
        if (name) {
            filtered = filtered.filter(a => 
                a.name.toLowerCase().includes(name.toLowerCase())
            );
        }
        
        // Filter by visibility
        if (visibility) {
            filtered = filtered.filter(a => a.visibility === visibility);
        }
        
        // Filter by assessment type
        if (assessmentType) {
            filtered = filtered.filter(a => a.assessmentType === assessmentType);
        }
        
        // Filter by deadline
        if (deadline) {
            const filterDate = new Date(deadline);
            filtered = filtered.filter(a => {
                const assessmentDate = new Date(a.deadline);
                return assessmentDate.toDateString() === filterDate.toDateString();
            });
        }
        
        renderAssessments(filtered);
    }

    // Clear filters
    function clearFilters() {
        document.getElementById('searchName').value = '';
        document.getElementById('filterVisibility').value = '';
        document.getElementById('filterAssessmentType').value = '';
        document.getElementById('filterDeadline').value = '';
        renderAssessments(assessments);
    }

    // Show create modal
    function showCreateModal() {
        document.getElementById('modalTitle').textContent = 'Create Assessment';
        document.getElementById('assessmentForm').reset();
        document.getElementById('assessmentId').value = '';
        document.getElementById('assessmentModal').classList.add('modal-open');
    }

    // Edit assessment
    function editAssessment(id) {
        const assessment = assessments.find(a => a.id === id);
        if (!assessment) return;
        
        document.getElementById('modalTitle').textContent = 'Edit Assessment';
        document.getElementById('assessmentId').value = assessment.id;
        document.getElementById('assessmentName').value = assessment.name;
        document.getElementById('assessmentDescription').value = assessment.description || '';
        document.getElementById('assessmentType').value = assessment.assessmentType;
        document.getElementById('assessmentVisibility').value = assessment.visibility;
        
        // Format deadline for datetime-local input
        const deadline = new Date(assessment.deadline);
        const formattedDeadline = deadline.toISOString().slice(0, 16);
        document.getElementById('assessmentDeadline').value = formattedDeadline;
        
        document.getElementById('assessmentModal').classList.add('modal-open');
    }

    // Close modal
    function closeModal() {
        document.getElementById('assessmentModal').classList.remove('modal-open');
    }

    // Save assessment (create or update)
    async function saveAssessment(event) {
        event.preventDefault();
        
        const id = document.getElementById('assessmentId').value;
        const formData = new URLSearchParams();
        formData.append('name', document.getElementById('assessmentName').value);
        formData.append('description', document.getElementById('assessmentDescription').value);
        formData.append('assessmentType', document.getElementById('assessmentType').value);
        formData.append('visibility', document.getElementById('assessmentVisibility').value);
        
        // Format deadline
        const deadlineInput = document.getElementById('assessmentDeadline').value;
        const deadline = new Date(deadlineInput);
        formData.append('deadline', deadline.toISOString().slice(0, 19).replace('T', 'T'));
        
        try {
            let response;
            if (id) {
                // Update
                formData.append('_method', 'PUT');
                response = await fetch(apiBase + '/' + id, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: formData.toString()
                });
            } else {
                // Create
                response = await fetch(apiBase, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: formData.toString()
                });
            }
            
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to save assessment');
            }
            
            closeModal();
            await loadAssessments();
            
            // Show success message
            alert(id ? 'Assessment updated successfully!' : 'Assessment created successfully!');
        } catch (error) {
            console.error('Error saving assessment:', error);
            alert('Error: ' + error.message);
        }
    }

    // Show delete modal
    function showDeleteModal(id) {
        deleteAssessmentId = id;
        document.getElementById('deleteModal').classList.add('modal-open');
    }

    // Close delete modal
    function closeDeleteModal() {
        deleteAssessmentId = null;
        document.getElementById('deleteModal').classList.remove('modal-open');
    }

    // Confirm delete
    async function confirmDelete() {
        if (!deleteAssessmentId) return;
        
        try {
            const formData = new URLSearchParams();
            formData.append('_method', 'DELETE');
            
            const response = await fetch(apiBase + '/' + deleteAssessmentId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: formData.toString()
            });
            
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to delete assessment');
            }
            
            closeDeleteModal();
            await loadAssessments();
            alert('Assessment deleted successfully!');
        } catch (error) {
            console.error('Error deleting assessment:', error);
            alert('Error: ' + error.message);
        }
    }

    // Utility functions
    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleString();
    }

    // Quiz Questions Management
    let currentQuizAssessmentId = null;
    let quizQuestions = [];
    const quizQuestionApi = '<%= request.getContextPath() %>/api/quiz-questions';

    async function manageQuizQuestions(assessmentId) {
        currentQuizAssessmentId = assessmentId;
        const assessment = assessments.find(a => a.id === assessmentId);
        if (!assessment) return;
        
        document.getElementById('quizQuestionsModalTitle').textContent = 
            'Manage Questions: ' + assessment.name;
        
        await loadQuizQuestions(assessmentId);
        document.getElementById('quizQuestionsModal').classList.add('modal-open');
    }

    async function loadQuizQuestions(assessmentId) {
        try {
            const response = await fetch(quizQuestionApi + '?assessmentId=' + assessmentId);
            if (!response.ok) throw new Error('Failed to load questions');
            
            quizQuestions = await response.json();
            renderQuizQuestions();
        } catch (error) {
            console.error('Error loading questions:', error);
            document.getElementById('quizQuestionsList').innerHTML = 
                '<div class="text-error">Error loading questions</div>';
        }
    }

    function renderQuizQuestions() {
        const container = document.getElementById('quizQuestionsList');
        
        if (quizQuestions.length === 0) {
            container.innerHTML = '<p class="text-gray-500">No questions yet. Add your first question!</p>';
            return;
        }
        
        container.innerHTML = quizQuestions.map(function(q, index) {
            return '<div class="card bg-base-200 p-4">' +
                '<div class="flex justify-between items-start mb-2">' +
                    '<div class="flex-1">' +
                        '<div class="font-bold">Question ' + (index + 1) + 
                        ' <span class="badge badge-sm">' + q.points + ' point' + (q.points > 1 ? 's' : '') + '</span></div>' +
                        '<p class="mt-2">' + escapeHtml(q.questionText) + '</p>' +
                        '<div class="mt-2 text-sm space-y-1">' +
                            '<div><strong>A:</strong> ' + escapeHtml(q.optionA) + 
                            (q.correctAnswer === 'A' ? ' <span class="badge badge-success badge-sm">Correct</span>' : '') + '</div>' +
                            '<div><strong>B:</strong> ' + escapeHtml(q.optionB) + 
                            (q.correctAnswer === 'B' ? ' <span class="badge badge-success badge-sm">Correct</span>' : '') + '</div>' +
                            (q.optionC ? '<div><strong>C:</strong> ' + escapeHtml(q.optionC) + 
                            (q.correctAnswer === 'C' ? ' <span class="badge badge-success badge-sm">Correct</span>' : '') + '</div>' : '') +
                            (q.optionD ? '<div><strong>D:</strong> ' + escapeHtml(q.optionD) + 
                            (q.correctAnswer === 'D' ? ' <span class="badge badge-success badge-sm">Correct</span>' : '') + '</div>' : '') +
                        '</div>' +
                    '</div>' +
                    '<div class="flex gap-2 ml-4">' +
                        '<button onclick="editQuestion(' + q.id + ')" class="btn btn-sm btn-primary">Edit</button>' +
                        '<button onclick="deleteQuestion(' + q.id + ')" class="btn btn-sm btn-error">Delete</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
        }).join('');
    }

    function showAddQuestionModal() {
        document.getElementById('questionModalTitle').textContent = 'Add Question';
        document.getElementById('questionForm').reset();
        document.getElementById('questionId').value = '';
        document.getElementById('questionAssessmentId').value = currentQuizAssessmentId;
        document.getElementById('questionPoints').value = '1';
        document.getElementById('questionModal').classList.add('modal-open');
    }

    async function editQuestion(questionId) {
        const question = quizQuestions.find(q => q.id === questionId);
        if (!question) return;
        
        document.getElementById('questionModalTitle').textContent = 'Edit Question';
        document.getElementById('questionId').value = question.id;
        document.getElementById('questionAssessmentId').value = question.assessmentId;
        document.getElementById('questionText').value = question.questionText;
        document.getElementById('optionA').value = question.optionA;
        document.getElementById('optionB').value = question.optionB;
        document.getElementById('optionC').value = question.optionC || '';
        document.getElementById('optionD').value = question.optionD || '';
        document.getElementById('correctAnswer').value = question.correctAnswer;
        document.getElementById('questionPoints').value = question.points;
        
        document.getElementById('questionModal').classList.add('modal-open');
    }

    async function saveQuestion(event) {
        event.preventDefault();
        
        const questionId = document.getElementById('questionId').value;
        const assessmentId = document.getElementById('questionAssessmentId').value;
        const formData = new URLSearchParams();
        formData.append('assessmentId', assessmentId);
        formData.append('questionText', document.getElementById('questionText').value);
        formData.append('optionA', document.getElementById('optionA').value);
        formData.append('optionB', document.getElementById('optionB').value);
        formData.append('optionC', document.getElementById('optionC').value);
        formData.append('optionD', document.getElementById('optionD').value);
        formData.append('correctAnswer', document.getElementById('correctAnswer').value);
        formData.append('points', document.getElementById('questionPoints').value);
        
        try {
            let response;
            if (questionId) {
                // Update
                formData.append('_method', 'PUT');
                response = await fetch(quizQuestionApi + '/' + questionId, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: formData.toString()
                });
            } else {
                // Create
                response = await fetch(quizQuestionApi, {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: formData.toString()
                });
            }
            
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to save question');
            }
            
            closeQuestionModal();
            await loadQuizQuestions(assessmentId);
        } catch (error) {
            console.error('Error saving question:', error);
            alert('Error: ' + error.message);
        }
    }

    async function deleteQuestion(questionId) {
        if (!confirm('Are you sure you want to delete this question?')) return;
        
        try {
            const formData = new URLSearchParams();
            formData.append('_method', 'DELETE');
            
            const response = await fetch(quizQuestionApi + '/' + questionId, {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: formData.toString()
            });
            
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to delete question');
            }
            
            await loadQuizQuestions(currentQuizAssessmentId);
        } catch (error) {
            console.error('Error deleting question:', error);
            alert('Error: ' + error.message);
        }
    }

    function closeQuestionModal() {
        document.getElementById('questionModal').classList.remove('modal-open');
    }

    function closeQuizQuestionsModal() {
        document.getElementById('quizQuestionsModal').classList.remove('modal-open');
        currentQuizAssessmentId = null;
        quizQuestions = [];
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>
