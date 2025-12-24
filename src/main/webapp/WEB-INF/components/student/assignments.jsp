<%--
  Student Assignments/Assessments View with Quiz and Submission Functionality
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
            session.getAttribute("role").toString() : "STUDENT";
    Long userId = (Long) session.getAttribute("userId");
%>
<div class="p-6">
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-gray-800 mb-2">My Assessments</h1>
        <p class="text-gray-600">View and submit your assignments, quizzes, and exams</p>
    </div>

    <!-- Filter Bar -->
    <div class="flex flex-wrap gap-4 mb-6 items-center">
        <div class="form-control">
            <input type="text" id="searchName" placeholder="Search by name..." 
                   class="input input-bordered w-64" />
        </div>
        
        <select id="filterAssessmentType" class="select select-bordered">
            <option value="">All Types</option>
            <option value="QUIZ">Quiz</option>
            <option value="ASSIGNMENT">Assignment</option>
            <option value="EXAM">Exam</option>
            <option value="PROJECT">Project</option>
            <option value="PRESENTATION">Presentation</option>
        </select>
        
        <select id="filterStatus" class="select select-bordered">
            <option value="">All Status</option>
            <option value="pending">Pending</option>
            <option value="submitted">Submitted</option>
            <option value="overdue">Overdue</option>
        </select>
        
        <button onclick="applyFilters()" class="btn btn-primary">Apply Filters</button>
        <button onclick="clearFilters()" class="btn btn-ghost">Clear</button>
    </div>

    <!-- Assessments Grid -->
    <div id="assessmentsContainer" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="col-span-full text-center">
            <span class="loading loading-spinner loading-lg"></span>
            <p class="mt-2">Loading assessments...</p>
        </div>
    </div>
</div>

<!-- Quiz Modal -->
<div id="quizModal" class="modal">
    <div class="modal-box w-11/12 max-w-4xl">
        <h3 class="font-bold text-lg mb-4" id="quizModalTitle">Take Quiz</h3>
        
        <div id="quizContent" class="space-y-4">
            <!-- Quiz questions will be loaded here -->
        </div>
        
        <div class="modal-action">
            <button onclick="closeQuizModal()" class="btn btn-ghost">Cancel</button>
            <button onclick="submitQuiz()" class="btn btn-primary">Submit Quiz</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeQuizModal()"></div>
</div>

<!-- Quiz Results Modal -->
<div id="quizResultsModal" class="modal">
    <div class="modal-box w-11/12 max-w-4xl">
        <h3 class="font-bold text-lg mb-4">Quiz Results</h3>
        
        <div id="quizResultsContent" class="space-y-4">
            <!-- Quiz results will be displayed here -->
        </div>
        
        <div class="modal-action">
            <button onclick="closeQuizResultsModal()" class="btn btn-primary">Close</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeQuizResultsModal()"></div>
</div>

<!-- Submission Modal (for assignments) -->
<div id="submissionModal" class="modal">
    <div class="modal-box w-11/12 max-w-3xl">
        <h3 class="font-bold text-lg mb-4">Submit Assessment</h3>
        
        <div id="assessmentDetails" class="mb-4 p-4 bg-base-200 rounded-lg">
            <!-- Assessment details will be populated here -->
        </div>
        
        <form id="submissionForm" onsubmit="submitAssessment(event)" enctype="multipart/form-data">
            <input type="hidden" id="submissionAssessmentId" />
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">Submission Content *</span>
                </label>
                <textarea id="submissionContent" placeholder="Enter your submission" 
                          class="textarea textarea-bordered" rows="6" required></textarea>
            </div>
            
            <div class="form-control mb-4">
                <label class="label">
                    <span class="label-text font-semibold">File Upload (Optional)</span>
                </label>
                <input type="file" id="submissionFile" name="file" class="file-input file-input-bordered w-full" />
            </div>
            
            <div class="modal-action">
                <button type="button" onclick="closeSubmissionModal()" class="btn btn-ghost">Cancel</button>
                <button type="submit" class="btn btn-primary">Submit</button>
            </div>
        </form>
    </div>
    <div class="modal-backdrop" onclick="closeSubmissionModal()"></div>
</div>

<!-- View Submission Modal -->
<div id="viewSubmissionModal" class="modal">
    <div class="modal-box w-11/12 max-w-3xl">
        <h3 class="font-bold text-lg mb-4">My Submission</h3>
        
        <div id="viewSubmissionContent" class="mb-4">
            <!-- Submission content will be populated here -->
        </div>
        
        <div class="modal-action">
            <button onclick="closeViewSubmissionModal()" class="btn btn-primary">Close</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeViewSubmissionModal()"></div>
</div>

<script>
    let assessments = [];
    let quizQuestions = {};
    let quizAnswers = {};
    let submissions = {};
    const apiBase = '<%= request.getContextPath() %>/api/assessments';
    const quizQuestionApi = '<%= request.getContextPath() %>/api/quiz-questions';
    const quizAnswerApi = '<%= request.getContextPath() %>/api/quiz-answers';
    const submissionApi = '<%= request.getContextPath() %>/api/submissions';
    const userId = <%= userId != null ? userId : 0 %>;
    let currentQuizAssessmentId = null;

    // Load assessments on page load
    document.addEventListener('DOMContentLoaded', function() {
        loadAssessments();
        loadSubmissions();
    });

    // Load all assessments
    async function loadAssessments() {
        try {
            const response = await fetch(apiBase);
            if (!response.ok) throw new Error('Failed to load assessments');
            
            const allAssessments = await response.json();
            assessments = allAssessments.filter(a => a.visibility === 'PUBLIC' || a.visibility === 'RESTRICTED');
            renderAssessments(assessments);
        } catch (error) {
            console.error('Error loading assessments:', error);
            document.getElementById('assessmentsContainer').innerHTML = 
                '<div class="col-span-full text-center text-error">Error loading assessments</div>';
        }
    }

    // Load submissions from API
    async function loadSubmissions() {
        try {
            const response = await fetch(submissionApi);
            if (response.ok) {
                const data = await response.json();
                data.forEach(function(sub) {
                    submissions[sub.assessmentId] = sub;
                });
            }
        } catch (error) {
            console.error('Error loading submissions:', error);
        }
    }

    // Render assessments as cards
    function renderAssessments(data) {
        const container = document.getElementById('assessmentsContainer');
        
        if (data.length === 0) {
            container.innerHTML = '<div class="col-span-full text-center">No assessments available</div>';
            return;
        }
        
        container.innerHTML = data.map(function(assessment) {
            const id = assessment.id;
            const name = escapeHtml(assessment.name || '');
            const description = escapeHtml((assessment.description || '').substring(0, 100));
            const type = assessment.assessmentType || '';
            const deadline = formatDate(assessment.deadline);
            const isOverdue = new Date(assessment.deadline) < new Date();
            const hasSubmission = submissions[id] != null;
            const status = hasSubmission ? 'submitted' : (isOverdue ? 'overdue' : 'pending');
            const statusClass = status === 'submitted' ? 'badge-success' : 
                               status === 'overdue' ? 'badge-error' : 'badge-warning';
            const statusText = status === 'submitted' ? 'Submitted' : 
                              status === 'overdue' ? 'Overdue' : 'Pending';
            
            const actionButton = hasSubmission ? 
                '<button onclick="viewSubmission(' + id + ')" class="btn btn-sm btn-info">View Submission</button>' :
                (type === 'QUIZ' ? 
                    '<button onclick="startQuiz(' + id + ')" class="btn btn-sm btn-primary"' + 
                    (isOverdue ? ' disabled title="Deadline has passed"' : '') + '>Take Quiz</button>' :
                    '<button onclick="showSubmissionModal(' + id + ')" class="btn btn-sm btn-primary"' + 
                    (isOverdue ? ' disabled title="Deadline has passed"' : '') + '>Submit</button>'
                );
            
            return '<div class="card bg-base-100 shadow-lg border border-gray-200">' +
                '<div class="card-body">' +
                    '<div class="flex justify-between items-start mb-2">' +
                        '<h2 class="card-title text-lg">' + name + '</h2>' +
                        '<span class="badge badge-info">' + type + '</span>' +
                    '</div>' +
                    '<p class="text-sm text-gray-600 mb-3">' + description + (assessment.description && assessment.description.length > 100 ? '...' : '') + '</p>' +
                    '<div class="space-y-2 mb-4">' +
                        '<div class="flex justify-between text-sm">' +
                            '<span class="text-gray-500">Deadline:</span>' +
                            '<span class="font-semibold' + (isOverdue ? ' text-error' : '') + '">' + deadline + '</span>' +
                        '</div>' +
                        '<div class="flex justify-between text-sm">' +
                            '<span class="text-gray-500">Status:</span>' +
                            '<span class="badge ' + statusClass + '">' + statusText + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div class="card-actions justify-end">' + actionButton + '</div>' +
                '</div>' +
            '</div>';
        }).join('');
    }

    // Start quiz
    async function startQuiz(assessmentId) {
        currentQuizAssessmentId = assessmentId;
        const assessment = assessments.find(a => a.id === assessmentId);
        if (!assessment) return;
        
        try {
            // Check if already answered
            const answerResponse = await fetch(quizAnswerApi + '?assessmentId=' + assessmentId);
            if (answerResponse.ok) {
                const existingAnswers = await answerResponse.json();
                if (existingAnswers.length > 0) {
                    alert('You have already taken this quiz. Viewing results...');
                    showQuizResults(assessmentId, existingAnswers);
                    return;
                }
            }
            
            // Load questions
            const response = await fetch(quizQuestionApi + '?assessmentId=' + assessmentId);
            if (!response.ok) throw new Error('Failed to load quiz questions');
            
            const questions = await response.json();
            if (questions.length === 0) {
                alert('No questions available for this quiz');
                return;
            }
            
            quizQuestions[assessmentId] = questions;
            quizAnswers[assessmentId] = {};
            
            // Render quiz
            document.getElementById('quizModalTitle').textContent = 'Quiz: ' + assessment.name;
            const quizContent = document.getElementById('quizContent');
            quizContent.innerHTML = questions.map(function(q, index) {
                return '<div class="card bg-base-200 p-4">' +
                    '<div class="mb-3">' +
                        '<span class="font-bold">Question ' + (index + 1) + ':</span> ' +
                        '<span class="badge badge-sm">' + q.points + ' point' + (q.points > 1 ? 's' : '') + '</span>' +
                    '</div>' +
                    '<p class="mb-3 font-semibold">' + escapeHtml(q.questionText) + '</p>' +
                    '<div class="space-y-2">' +
                        '<label class="flex items-center gap-2 cursor-pointer">' +
                            '<input type="radio" name="question_' + q.id + '" value="A" class="radio radio-primary" />' +
                            '<span>' + escapeHtml(q.optionA) + '</span>' +
                        '</label>' +
                        '<label class="flex items-center gap-2 cursor-pointer">' +
                            '<input type="radio" name="question_' + q.id + '" value="B" class="radio radio-primary" />' +
                            '<span>' + escapeHtml(q.optionB) + '</span>' +
                        '</label>' +
                        (q.optionC ? '<label class="flex items-center gap-2 cursor-pointer">' +
                            '<input type="radio" name="question_' + q.id + '" value="C" class="radio radio-primary" />' +
                            '<span>' + escapeHtml(q.optionC) + '</span>' +
                        '</label>' : '') +
                        (q.optionD ? '<label class="flex items-center gap-2 cursor-pointer">' +
                            '<input type="radio" name="question_' + q.id + '" value="D" class="radio radio-primary" />' +
                            '<span>' + escapeHtml(q.optionD) + '</span>' +
                        '</label>' : '') +
                    '</div>' +
                '</div>';
            }).join('');
            
            document.getElementById('quizModal').classList.add('modal-open');
        } catch (error) {
            console.error('Error loading quiz:', error);
            alert('Error loading quiz: ' + error.message);
        }
    }

    // Submit quiz
    async function submitQuiz() {
        if (!currentQuizAssessmentId) return;
        
        const questions = quizQuestions[currentQuizAssessmentId];
        if (!questions) return;
        
        const answers = {};
        let allAnswered = true;
        
        questions.forEach(function(q) {
            const selected = document.querySelector('input[name="question_' + q.id + '"]:checked');
            if (selected) {
                answers[q.id] = selected.value;
            } else {
                allAnswered = false;
            }
        });
        
        if (!allAnswered) {
            if (!confirm('You have not answered all questions. Submit anyway?')) {
                return;
            }
        }
        
        try {
            // Submit all answers
            const submitPromises = [];
            for (const questionId in answers) {
                const formData = new URLSearchParams();
                formData.append('questionId', questionId);
                formData.append('selectedAnswer', answers[questionId]);
                
                submitPromises.push(
                    fetch(quizAnswerApi, {
                        method: 'POST',
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: formData.toString()
                    })
                );
            }
            
            await Promise.all(submitPromises);
            
            // Get results
            const response = await fetch(quizAnswerApi + '?assessmentId=' + currentQuizAssessmentId);
            const submittedAnswers = await response.json();
            
            closeQuizModal();
            showQuizResults(currentQuizAssessmentId, submittedAnswers);
        } catch (error) {
            console.error('Error submitting quiz:', error);
            alert('Error submitting quiz: ' + error.message);
        }
    }

    // Show quiz results
    async function showQuizResults(assessmentId, answers) {
        const questions = quizQuestions[assessmentId];
        if (!questions) {
            // Load questions if not loaded
            const response = await fetch(quizQuestionApi + '?assessmentId=' + assessmentId);
            if (response.ok) {
                quizQuestions[assessmentId] = await response.json();
            }
        }
        
        const questionsList = quizQuestions[assessmentId] || [];
        const answerMap = {};
        answers.forEach(function(a) {
            answerMap[a.questionId] = a;
        });
        
        let totalPoints = 0;
        let earnedPoints = 0;
        
        const resultsHtml = questionsList.map(function(q, index) {
            const answer = answerMap[q.id];
            const isCorrect = answer && answer.isCorrect;
            const selected = answer ? answer.selectedAnswer : 'Not answered';
            const correct = q.correctAnswer;
            
            totalPoints += q.points;
            if (isCorrect) earnedPoints += q.points;
            
            return '<div class="card ' + (isCorrect ? 'bg-success' : 'bg-error') + ' bg-opacity-10 p-4">' +
                '<div class="mb-2">' +
                    '<span class="font-bold">Question ' + (index + 1) + ':</span> ' +
                    '<span class="badge ' + (isCorrect ? 'badge-success' : 'badge-error') + '">' + 
                    (isCorrect ? 'Correct' : 'Incorrect') + '</span>' +
                '</div>' +
                '<p class="mb-2">' + escapeHtml(q.questionText) + '</p>' +
                '<div class="text-sm space-y-1">' +
                    '<div><strong>Your Answer:</strong> ' + selected + 
                    (isCorrect ? ' <span class="text-success">✓</span>' : ' <span class="text-error">✗</span>') + '</div>' +
                    '<div><strong>Correct Answer:</strong> ' + correct + '</div>' +
                    '<div><strong>Points:</strong> ' + (isCorrect ? q.points : 0) + ' / ' + q.points + '</div>' +
                '</div>' +
            '</div>';
        }).join('');
        
        const summaryHtml = '<div class="card bg-primary text-primary-content p-6 mb-4">' +
            '<h4 class="text-2xl font-bold mb-2">Quiz Results</h4>' +
            '<div class="text-3xl font-bold">' + earnedPoints + ' / ' + totalPoints + ' points</div>' +
            '<div class="text-lg mt-2">' + Math.round((earnedPoints / totalPoints) * 100) + '%</div>' +
        '</div>';
        
        document.getElementById('quizResultsContent').innerHTML = summaryHtml + resultsHtml;
        document.getElementById('quizResultsModal').classList.add('modal-open');
        
        // Reload assessments to update status
        await loadAssessments();
    }

    // Close quiz modal
    function closeQuizModal() {
        document.getElementById('quizModal').classList.remove('modal-open');
        currentQuizAssessmentId = null;
    }

    // Close quiz results modal
    function closeQuizResultsModal() {
        document.getElementById('quizResultsModal').classList.remove('modal-open');
    }

    // Show submission modal (for assignments)
    function showSubmissionModal(id) {
        const assessment = assessments.find(a => a.id === id);
        if (!assessment) return;
        
        document.getElementById('submissionAssessmentId').value = id;
        document.getElementById('submissionForm').reset();
        
        const details = '<h4 class="font-bold mb-2">' + escapeHtml(assessment.name) + '</h4>' +
            '<p class="text-sm mb-2">' + escapeHtml(assessment.description || 'No description') + '</p>' +
            '<div class="text-sm">' +
                '<p><strong>Type:</strong> ' + assessment.assessmentType + '</p>' +
                '<p><strong>Deadline:</strong> ' + formatDate(assessment.deadline) + '</p>' +
            '</div>';
        document.getElementById('assessmentDetails').innerHTML = details;
        document.getElementById('submissionModal').classList.add('modal-open');
    }

    // Close submission modal
    function closeSubmissionModal() {
        document.getElementById('submissionModal').classList.remove('modal-open');
    }

    // Submit assessment (non-quiz)
    async function submitAssessment(event) {
        event.preventDefault();
        
        const assessmentId = parseInt(document.getElementById('submissionAssessmentId').value);
        const content = document.getElementById('submissionContent').value;
        const fileInput = document.getElementById('submissionFile');
        
        if (!content.trim()) {
            alert('Please enter submission content');
            return;
        }
        
        try {
            const formData = new FormData();
            formData.append('assessmentId', assessmentId);
            formData.append('submissionContent', content);
            if (fileInput.files.length > 0) {
                formData.append('file', fileInput.files[0]);
            }
            
            const response = await fetch(submissionApi, {
                method: 'POST',
                body: formData
            });
            
            if (!response.ok) {
                const error = await response.json();
                throw new Error(error.error || 'Failed to submit');
            }
            
            closeSubmissionModal();
            await loadSubmissions();
            await loadAssessments();
            alert('Submission successful!');
        } catch (error) {
            console.error('Error submitting assessment:', error);
            alert('Error: ' + error.message);
        }
    }

    // View submission
    async function viewSubmission(id) {
        try {
            const response = await fetch(submissionApi + '?assessmentId=' + id);
            if (!response.ok) throw new Error('Failed to load submission');
            
            const submission = await response.json();
            const assessment = assessments.find(a => a.id === id);
            
            let content = '<div class="space-y-4">' +
                '<div><strong>Assessment:</strong> ' + escapeHtml(assessment ? assessment.name : 'Unknown') + '</div>' +
                '<div><strong>Submitted:</strong> ' + formatDate(submission.submittedAt) + '</div>';
            
            if (submission.marks != null) {
                content += '<div><strong>Marks:</strong> ' + submission.marks + 
                    (submission.maxMarks ? ' / ' + submission.maxMarks : '') + '</div>';
            }
            if (submission.feedback) {
                content += '<div><strong>Feedback:</strong> ' + escapeHtml(submission.feedback) + '</div>';
            }
            
            content += '<div><strong>Content:</strong></div>' +
                '<div class="p-4 bg-base-200 rounded">' + escapeHtml(submission.submissionContent || '') + '</div>';
            
            if (submission.fileName) {
                content += '<div><strong>File:</strong> ' + escapeHtml(submission.fileName) + '</div>';
            }
            
            content += '</div>';
            
            document.getElementById('viewSubmissionContent').innerHTML = content;
            document.getElementById('viewSubmissionModal').classList.add('modal-open');
        } catch (error) {
            console.error('Error loading submission:', error);
            alert('Error loading submission: ' + error.message);
        }
    }

    // Close view submission modal
    function closeViewSubmissionModal() {
        document.getElementById('viewSubmissionModal').classList.remove('modal-open');
    }

    // Apply filters
    function applyFilters() {
        const name = document.getElementById('searchName').value.trim().toLowerCase();
        const assessmentType = document.getElementById('filterAssessmentType').value;
        const status = document.getElementById('filterStatus').value;
        
        let filtered = [...assessments];
        
        if (name) {
            filtered = filtered.filter(a => (a.name || '').toLowerCase().includes(name));
        }
        if (assessmentType) {
            filtered = filtered.filter(a => a.assessmentType === assessmentType);
        }
        if (status) {
            filtered = filtered.filter(a => {
                const isOverdue = new Date(a.deadline) < new Date();
                const hasSubmission = submissions[a.id] != null;
                if (status === 'submitted') return hasSubmission;
                if (status === 'overdue') return isOverdue && !hasSubmission;
                if (status === 'pending') return !isOverdue && !hasSubmission;
                return true;
            });
        }
        
        renderAssessments(filtered);
    }

    // Clear filters
    function clearFilters() {
        document.getElementById('searchName').value = '';
        document.getElementById('filterAssessmentType').value = '';
        document.getElementById('filterStatus').value = '';
        renderAssessments(assessments);
    }

    // Utility functions
    function formatDate(dateString) {
        if (!dateString) return '-';
        const date = new Date(dateString);
        return date.toLocaleString();
    }

    function escapeHtml(text) {
        if (!text) return '';
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
</script>
