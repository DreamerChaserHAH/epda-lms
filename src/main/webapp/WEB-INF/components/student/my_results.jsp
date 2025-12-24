<%--
  Student Results Page showing graded assessments
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
        <h1 class="text-3xl font-bold text-gray-800 mb-2">My Results</h1>
        <p class="text-gray-600">View your graded assessments and quiz results</p>
    </div>

    <!-- Statistics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500">Total Graded</h3>
                <p class="text-3xl font-bold" id="totalGraded">-</p>
            </div>
        </div>
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500">Average Score</h3>
                <p class="text-3xl font-bold" id="averageScore">-</p>
            </div>
        </div>
        <div class="card bg-base-100 shadow-lg">
            <div class="card-body">
                <h3 class="card-title text-gray-500">Highest Score</h3>
                <p class="text-3xl font-bold" id="highestScore">-</p>
            </div>
        </div>
    </div>

    <!-- Filter Bar -->
    <div class="flex flex-wrap gap-4 mb-6 items-center">
        <select id="filterAssessmentType" class="select select-bordered">
            <option value="">All Types</option>
            <option value="QUIZ">Quiz</option>
            <option value="ASSIGNMENT">Assignment</option>
            <option value="EXAM">Exam</option>
            <option value="PROJECT">Project</option>
            <option value="PRESENTATION">Presentation</option>
        </select>
        
        <button onclick="applyFilters()" class="btn btn-primary">Apply Filters</button>
        <button onclick="clearFilters()" class="btn btn-ghost">Clear</button>
    </div>

    <!-- Results Table -->
    <div class="card bg-base-100 shadow-lg">
        <div class="card-body">
            <div class="overflow-x-auto">
                <table class="table table-zebra w-full">
                    <thead>
                        <tr>
                            <th>Assessment</th>
                            <th>Type</th>
                            <th>Submitted</th>
                            <th>Graded</th>
                            <th>Marks</th>
                            <th>Percentage</th>
                            <th>Feedback</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="resultsTableBody">
                        <tr>
                            <td colspan="8" class="text-center">
                                <span class="loading loading-spinner loading-lg"></span>
                                <p class="mt-2">Loading results...</p>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- View Details Modal -->
<div id="detailsModal" class="modal">
    <div class="modal-box w-11/12 max-w-4xl">
        <h3 class="font-bold text-lg mb-4" id="detailsModalTitle">Assessment Details</h3>
        <div id="detailsContent" class="space-y-4">
            <!-- Details will be populated here -->
        </div>
        <div class="modal-action">
            <button onclick="closeDetailsModal()" class="btn btn-primary">Close</button>
        </div>
    </div>
    <div class="modal-backdrop" onclick="closeDetailsModal()"></div>
</div>

<script>
    let submissions = [];
    let assessments = [];
    let quizAnswers = {};
    const apiBase = '<%= request.getContextPath() %>/api/assessments';
    const submissionApi = '<%= request.getContextPath() %>/api/submissions';
    const quizAnswerApi = '<%= request.getContextPath() %>/api/quiz-answers';
    const quizQuestionApi = '<%= request.getContextPath() %>/api/quiz-questions';
    const userId = <%= userId != null ? userId : 0 %>;

    document.addEventListener('DOMContentLoaded', function() {
        loadResults();
    });

    async function loadResults() {
        try {
            // Load assessments first
            const assessResponse = await fetch(apiBase);
            if (assessResponse.ok) {
                assessments = await assessResponse.json();
            }
            
            // Load submissions (assignments that have been graded by lecturer)
            const subResponse = await fetch(submissionApi);
            if (subResponse.ok) {
                const allSubmissions = await subResponse.json();
                // Filter to only show graded submissions (where lecturer has marked them)
                submissions = allSubmissions.filter(function(s) {
                    const studentId = s.studentId || (s.student && s.student.userId);
                    return studentId === userId && 
                           (s.status === 'GRADED' || (s.marks != null && s.marks >= 0));
                });
            }
            
            // Load quiz results (quizzes are auto-graded when submitted)
            await loadQuizResults();
            
            renderResults();
            updateStatistics();
        } catch (error) {
            console.error('Error loading results:', error);
            document.getElementById('resultsTableBody').innerHTML = 
                '<tr><td colspan="8" class="text-center text-error">Error loading results: ' + error.message + '</td></tr>';
        }
    }

    async function loadQuizResults() {
        // Load quiz results for all assessments
        for (const assessment of assessments) {
            if (assessment.assessmentType === 'QUIZ') {
                try {
                    const response = await fetch(quizAnswerApi + '?assessmentId=' + assessment.id + '&studentId=' + userId);
                    if (response.ok) {
                        const answers = await response.json();
                        if (answers && answers.length > 0) {
                            quizAnswers[assessment.id] = answers;
                            
                            // Calculate quiz score
                            const questionsResponse = await fetch(quizQuestionApi + '?assessmentId=' + assessment.id);
                            if (questionsResponse.ok) {
                                const questions = await questionsResponse.json();
                                if (questions && questions.length > 0) {
                                    let totalPoints = 0;
                                    let earnedPoints = 0;
                                    
                                    questions.forEach(function(q) {
                                        totalPoints += (q.points || 1);
                                        const answer = answers.find(function(a) {
                                            return a.question && a.question.id === q.id;
                                        });
                                        if (answer && answer.isCorrect) {
                                            earnedPoints += (q.points || 1);
                                        }
                                    });
                                    
                                    // Create a submission-like object for quiz (quizzes are auto-graded)
                                    const existingIndex = submissions.findIndex(function(s) {
                                        return s.assessmentId === assessment.id && s.isQuiz === true;
                                    });
                                    
                                    const quizResult = {
                                        id: 'quiz_' + assessment.id,
                                        assessmentId: assessment.id,
                                        assessmentType: 'QUIZ',
                                        marks: earnedPoints,
                                        maxMarks: totalPoints,
                                        submittedAt: answers[0].answeredAt || new Date().toISOString(),
                                        gradedAt: answers[0].answeredAt || new Date().toISOString(),
                                        status: 'GRADED',
                                        isQuiz: true,
                                        feedback: 'Auto-graded quiz'
                                    };
                                    
                                    if (existingIndex >= 0) {
                                        submissions[existingIndex] = quizResult;
                                    } else {
                                        submissions.push(quizResult);
                                    }
                                }
                            }
                        }
                    }
                } catch (error) {
                    console.error('Error loading quiz results for assessment ' + assessment.id, error);
                }
            }
        }
    }

    function renderResults() {
        const tbody = document.getElementById('resultsTableBody');
        
        if (submissions.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center">No graded assessments yet</td></tr>';
            return;
        }
        
        tbody.innerHTML = submissions.map(function(sub) {
            const assessment = assessments.find(function(a) {
                return a.id === sub.assessmentId;
            });
            if (!assessment) return '';
            
            const marks = sub.marks != null ? sub.marks : 0;
            const maxMarks = sub.maxMarks != null ? sub.maxMarks : 100;
            const percentage = maxMarks > 0 ? Math.round((marks / maxMarks) * 100) : 0;
            const percentageClass = percentage >= 80 ? 'text-success' : 
                                   percentage >= 60 ? 'text-warning' : 'text-error';
            
            return '<tr>' +
                '<td class="font-semibold">' + escapeHtml(assessment.name || 'Unknown') + '</td>' +
                '<td><span class="badge badge-info">' + (assessment.assessmentType || 'UNKNOWN') + '</span></td>' +
                '<td>' + formatDate(sub.submittedAt) + '</td>' +
                '<td>' + (sub.gradedAt ? formatDate(sub.gradedAt) : (sub.isQuiz ? formatDate(sub.submittedAt) : '-')) + '</td>' +
                '<td><span class="font-bold">' + marks + ' / ' + maxMarks + '</span></td>' +
                '<td><span class="font-bold ' + percentageClass + '">' + percentage + '%</span></td>' +
                '<td>' + (sub.feedback ? escapeHtml(sub.feedback.substring(0, 50)) + 
                         (sub.feedback.length > 50 ? '...' : '') : (sub.isQuiz ? 'Auto-graded' : '-')) + '</td>' +
                '<td>' +
                    '<button onclick="viewDetails(' + sub.assessmentId + ', ' + 
                    (sub.isQuiz ? 'true' : 'false') + ')" class="btn btn-sm btn-primary">View Details</button>' +
                '</td>' +
            '</tr>';
        }).join('');
    }

    async function viewDetails(assessmentId, isQuiz) {
        const assessment = assessments.find(function(a) {
            return a.id === assessmentId;
        });
        if (!assessment) return;
        
        document.getElementById('detailsModalTitle').textContent = 'Results: ' + assessment.name;
        
        let content = '<div class="space-y-4">' +
            '<div><strong>Assessment:</strong> ' + escapeHtml(assessment.name) + '</div>' +
            '<div><strong>Type:</strong> ' + assessment.assessmentType + '</div>';
        
        if (isQuiz) {
            // Show quiz results with questions and answers
            const answers = quizAnswers[assessmentId] || [];
            const questionsResponse = await fetch(quizQuestionApi + '?assessmentId=' + assessmentId);
            if (questionsResponse.ok) {
                const questions = await questionsResponse.json();
                if (questions && questions.length > 0) {
                    let totalPoints = 0;
                    let earnedPoints = 0;
                    
                    content += '<div class="divider">Quiz Questions & Answers</div>';
                    content += '<div class="space-y-4">';
                    
                    questions.forEach(function(q, index) {
                        const qPoints = q.points || 1;
                        totalPoints += qPoints;
                        const answer = answers.find(function(a) {
                            return a.question && a.question.id === q.id;
                        });
                        const isCorrect = answer && answer.isCorrect;
                        if (isCorrect) earnedPoints += qPoints;
                        
                        content += '<div class="card ' + (isCorrect ? 'bg-success' : 'bg-error') + ' bg-opacity-10 p-4">' +
                            '<div class="mb-2">' +
                                '<span class="font-bold">Question ' + (index + 1) + ':</span> ' +
                                '<span class="badge ' + (isCorrect ? 'badge-success' : 'badge-error') + '">' + 
                                (isCorrect ? 'Correct' : 'Incorrect') + '</span>' +
                            '</div>' +
                            '<p class="mb-2">' + escapeHtml(q.questionText || '') + '</p>' +
                            '<div class="text-sm space-y-1">' +
                                '<div><strong>Your Answer:</strong> ' + (answer && answer.selectedAnswer ? answer.selectedAnswer : 'Not answered') + '</div>' +
                                '<div><strong>Correct Answer:</strong> ' + (q.correctAnswer || 'N/A') + '</div>' +
                                '<div><strong>Points:</strong> ' + (isCorrect ? qPoints : 0) + ' / ' + qPoints + '</div>' +
                            '</div>' +
                        '</div>';
                    });
                    
                    content += '</div>';
                    content += '<div class="card bg-primary text-primary-content p-4 mt-4">' +
                        '<div class="text-2xl font-bold">Total Score: ' + earnedPoints + ' / ' + totalPoints + '</div>' +
                        '<div class="text-lg">Percentage: ' + (totalPoints > 0 ? Math.round((earnedPoints / totalPoints) * 100) : 0) + '%</div>' +
                    '</div>';
                } else {
                    content += '<div class="alert alert-warning">No questions found for this quiz</div>';
                }
            }
        } else {
            // Show assignment submission details
            const subResponse = await fetch(submissionApi + '?assessmentId=' + assessmentId);
            if (subResponse.ok) {
                const submission = await subResponse.json();
                content += '<div><strong>Submitted:</strong> ' + formatDate(submission.submittedAt) + '</div>';
                if (submission.marks != null) {
                    content += '<div><strong>Marks:</strong> ' + submission.marks + 
                        (submission.maxMarks ? ' / ' + submission.maxMarks : '') + '</div>';
                    const percentage = submission.maxMarks > 0 ? 
                        Math.round((submission.marks / submission.maxMarks) * 100) : 0;
                    content += '<div><strong>Percentage:</strong> ' + percentage + '%</div>';
                }
                if (submission.feedback) {
                    content += '<div><strong>Feedback:</strong></div>' +
                        '<div class="p-4 bg-base-200 rounded">' + escapeHtml(submission.feedback) + '</div>';
                }
                if (submission.submissionContent) {
                    content += '<div><strong>Your Submission:</strong></div>' +
                        '<div class="p-4 bg-base-200 rounded">' + escapeHtml(submission.submissionContent) + '</div>';
                }
            }
        }
        
        content += '</div>';
        document.getElementById('detailsContent').innerHTML = content;
        document.getElementById('detailsModal').classList.add('modal-open');
    }

    function closeDetailsModal() {
        document.getElementById('detailsModal').classList.remove('modal-open');
    }

    function applyFilters() {
        const assessmentType = document.getElementById('filterAssessmentType').value;
        let filtered = [...submissions];
        
        if (assessmentType) {
            filtered = filtered.filter(function(s) {
                const assessment = assessments.find(function(a) {
                    return a.id === s.assessmentId;
                });
                return assessment && assessment.assessmentType === assessmentType;
            });
        }
        
        const tbody = document.getElementById('resultsTableBody');
        if (filtered.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center">No results found</td></tr>';
            return;
        }
        
        tbody.innerHTML = filtered.map(function(sub) {
            const assessment = assessments.find(function(a) {
                return a.id === sub.assessmentId;
            });
            if (!assessment) return '';
            
            const marks = sub.marks != null ? sub.marks : 0;
            const maxMarks = sub.maxMarks != null ? sub.maxMarks : 100;
            const percentage = maxMarks > 0 ? Math.round((marks / maxMarks) * 100) : 0;
            const percentageClass = percentage >= 80 ? 'text-success' : 
                                   percentage >= 60 ? 'text-warning' : 'text-error';
            
            return '<tr>' +
                '<td class="font-semibold">' + escapeHtml(assessment.name) + '</td>' +
                '<td><span class="badge badge-info">' + assessment.assessmentType + '</span></td>' +
                '<td>' + formatDate(sub.submittedAt) + '</td>' +
                '<td>' + (sub.gradedAt ? formatDate(sub.gradedAt) : '-') + '</td>' +
                '<td><span class="font-bold">' + marks + ' / ' + maxMarks + '</span></td>' +
                '<td><span class="font-bold ' + percentageClass + '">' + percentage + '%</span></td>' +
                '<td>' + (sub.feedback ? escapeHtml(sub.feedback.substring(0, 50)) + 
                         (sub.feedback.length > 50 ? '...' : '') : '-') + '</td>' +
                '<td>' +
                    '<button onclick="viewDetails(' + sub.assessmentId + ', ' + 
                    (sub.isQuiz ? 'true' : 'false') + ')" class="btn btn-sm btn-primary">View Details</button>' +
                '</td>' +
            '</tr>';
        }).join('');
    }

    function clearFilters() {
        document.getElementById('filterAssessmentType').value = '';
        renderResults();
    }

    function updateStatistics() {
        const graded = submissions.length;
        document.getElementById('totalGraded').textContent = graded;
        
        if (graded === 0) {
            document.getElementById('averageScore').textContent = '-';
            document.getElementById('highestScore').textContent = '-';
            return;
        }
        
        let totalMarks = 0;
        let totalMaxMarks = 0;
        let highest = 0;
        
        submissions.forEach(function(sub) {
            const marks = sub.marks != null ? sub.marks : 0;
            const maxMarks = sub.maxMarks != null ? sub.maxMarks : 100;
            totalMarks += marks;
            totalMaxMarks += maxMarks;
            const percentage = maxMarks > 0 ? (marks / maxMarks) * 100 : 0;
            if (percentage > highest) highest = percentage;
        });
        
        const average = totalMaxMarks > 0 ? Math.round((totalMarks / totalMaxMarks) * 100) : 0;
        document.getElementById('averageScore').textContent = average + '%';
        document.getElementById('highestScore').textContent = Math.round(highest) + '%';
    }

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

