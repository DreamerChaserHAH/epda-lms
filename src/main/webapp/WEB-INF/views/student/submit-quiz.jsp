<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="com.htetaung.lms.models.dto.QuizIndividualQuestionDTO" %>
<%@ page import="java.util.List" %>
<%
    // Check if this JSP is being included
    if (request.getAttribute("jakarta.servlet.include.request_uri") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    AssessmentDTO assessment = (AssessmentDTO) request.getAttribute("assessment");
    String contextPath = request.getContextPath();
    Long studentId = (Long) request.getSession().getAttribute("userId");
    String assessmentIdString = request.getParameter("assessmentId");

    // Fetch quiz questions if not already loaded
    if (request.getAttribute("questions") == null && assessmentIdString != null) {
        request.setAttribute("includingPage", "/WEB-INF/views/student/submit-quiz.jsp");
        request.getRequestDispatcher("/api/quiz-questions?quizId=" + assessmentIdString).include(request, response);
        return;
    }

    List<QuizIndividualQuestionDTO> questions = (List<QuizIndividualQuestionDTO>) request.getAttribute("questions");

    if (assessment == null) {
        response.sendRedirect(contextPath + "/index.jsp?page=assignments");
        return;
    }
%>

<div class="container mx-auto p-6">
    <!-- Header Section -->
    <div class="flex items-center justify-between pb-3 pt-3">
        <div>
            <h2 class="font-title font-bold text-3xl text-base-content">Take Quiz</h2>
            <p class="text-base-content/70 mt-1"><%= assessment.getAssessmentName() %></p>
        </div>
        <div class="flex items-center gap-3">
            <!-- Timer Display -->
            <div class="badge badge-error badge-lg gap-2 p-4">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <span id="timer" class="font-bold text-lg">10:00</span>
            </div>
            <button type="button"
                    class="btn btn-ghost btn-sm"
                    onclick="confirmExit()">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
                Exit
            </button>
        </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
        <!-- Quiz Details Sidebar -->
        <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow-xl border border-base-300 sticky top-6">
                <div class="card-body">
                    <h3 class="card-title text-primary text-sm mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Quiz Info
                    </h3>

                    <div class="space-y-3 text-sm">
                        <div>
                            <label class="text-xs font-semibold text-base-content/70">Questions</label>
                            <p class="text-base-content font-bold text-2xl"><%= questions != null ? questions.size() : 0 %></p>
                        </div>

                        <div>
                            <label class="text-xs font-semibold text-base-content/70">Time Limit</label>
                            <p class="text-base-content font-medium">10 minutes</p>
                        </div>

                        <div>
                            <label class="text-xs font-semibold text-base-content/70">Deadline</label>
                            <p class="text-error font-bold text-sm">
                                <%= new java.text.SimpleDateFormat("MMM dd, HH:mm").format(assessment.getDeadline()) %>
                            </p>
                        </div>

                        <div class="divider my-2"></div>

                        <!-- Question Navigation -->
                        <div>
                            <label class="text-xs font-semibold text-base-content/70 mb-2 block">Quick Navigation</label>
                            <div class="grid grid-cols-5 gap-2">
                                <% if (questions != null) {
                                    for (int i = 0; i < questions.size(); i++) { %>
                                <button type="button"
                                        onclick="scrollToQuestion(<%= i + 1 %>)"
                                        class="btn btn-sm btn-outline question-nav-btn"
                                        id="nav-btn-<%= i + 1 %>">
                                    <%= i + 1 %>
                                </button>
                                <% }
                                } %>
                            </div>
                        </div>

                        <div class="alert alert-warning text-xs p-2 mt-4">
                            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-4 w-4" fill="none" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                            </svg>
                            <span>Auto-submits when time expires</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quiz Questions -->
        <div class="lg:col-span-3">
            <form id="quizForm" action="<%= contextPath %>/api/quiz-submissions" method="POST">
                <input type="hidden" name="assessmentId" value="<%= assessment.getAssessmentId() %>">
                <input type="hidden" name="studentId" value="<%= studentId %>">

                <div class="space-y-6">
                    <% if (questions != null && !questions.isEmpty()) {
                        int questionNumber = 1;
                        for (QuizIndividualQuestionDTO question : questions) { %>

                    <div class="card bg-base-100 shadow-xl border border-base-300 question-card" id="question-<%= questionNumber %>" data-question="<%= questionNumber %>">
                        <div class="card-body">
                            <div class="flex items-start justify-between mb-4">
                                <h3 class="font-bold text-lg flex items-center gap-3">
                                    <span class="badge badge-primary badge-lg">Question <%= questionNumber %></span>
                                    <span><%= question.getQuestionText() %></span>
                                </h3>
                                <span class="badge badge-ghost">1 point</span>
                            </div>

                            <div class="space-y-3">
                                <%
                                    List<String> options = question.getOptions();
                                    for (int i = 0; i < options.size(); i++) {
                                        char optionLabel = (char)('A' + i);
                                %>
                                <label class="label cursor-pointer justify-start gap-4 bg-base-200 p-4 rounded-lg hover:bg-base-300 transition-colors">
                                    <input type="radio"
                                           name="question_<%= question.getQuizQuestionId() %>"
                                           value="<%= i %>"
                                           class="radio radio-primary"
                                           onchange="markQuestionAnswered(<%= questionNumber %>)">
                                    <span class="label-text flex-1">
                                        <span class="badge badge-outline badge-sm mr-2"><%= optionLabel %></span>
                                        <%= options.get(i) %>
                                    </span>
                                </label>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <%
                        questionNumber++;
                        }
                    } else { %>

                    <div class="alert alert-warning">
                        <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                        </svg>
                        <span>This quiz has no questions yet.</span>
                    </div>

                    <% } %>

                    <!-- Submit Button -->
                    <div class="card bg-base-100 shadow-xl border border-primary">
                        <div class="card-body">
                            <div class="flex items-center justify-between">
                                <div>
                                    <h4 class="font-bold text-lg">Ready to Submit?</h4>
                                    <p class="text-sm text-base-content/70">Review your answers before submitting</p>
                                    <p class="text-sm font-semibold mt-2">
                                        Answered: <span id="answered-count">0</span> / <%= questions != null ? questions.size() : 0 %>
                                    </p>
                                </div>
                                <button type="button"
                                        onclick="confirmSubmit()"
                                        class="btn btn-success btn-lg text-white">
                                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                    Submit Quiz
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Timer functionality
    let timeLeft = 600; // 10 minutes in seconds
    let timerInterval;

    function startTimer() {
        timerInterval = setInterval(() => {
            timeLeft--;
            updateTimerDisplay();

            if (timeLeft <= 0) {
                clearInterval(timerInterval);
                alert('Time is up! Your quiz will be submitted automatically.');
                document.getElementById('quizForm').submit();
            } else if (timeLeft <= 60) {
                document.getElementById('timer').classList.add('animate-pulse');
            }
        }, 1000);
    }

    function updateTimerDisplay() {
        const minutes = Math.floor(timeLeft / 60);
        const seconds = timeLeft % 60;
        document.getElementById('timer').textContent =
            `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }

    // Track answered questions
    function markQuestionAnswered(questionNum) {
        const navBtn = document.getElementById('nav-btn-' + questionNum);
        if (navBtn) {
            navBtn.classList.remove('btn-outline');
            navBtn.classList.add('btn-success');
        }
        updateAnsweredCount();
    }

    function updateAnsweredCount() {
        const totalQuestions = document.querySelectorAll('.question-card').length;
        const answeredQuestions = document.querySelectorAll('input[type="radio"]:checked').length;
        document.getElementById('answered-count').textContent = answeredQuestions;
    }

    function scrollToQuestion(questionNum) {
        const element = document.getElementById('question-' + questionNum);
        if (element) {
            element.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
    }

    function confirmSubmit() {
        const totalQuestions = document.querySelectorAll('.question-card').length;
        const answeredQuestions = document.querySelectorAll('input[type="radio"]:checked').length;

        if (answeredQuestions < totalQuestions) {
            if (!confirm(`You have only answered ${answeredQuestions} out of ${totalQuestions} questions. Do you want to submit anyway?`)) {
                return;
            }
        }

        if (confirm('Are you sure you want to submit this quiz? You cannot change your answers after submission.')) {
            clearInterval(timerInterval);
            document.getElementById('quizForm').submit();
        }
    }

    function confirmExit() {
        if (confirm('Are you sure you want to exit? Your progress will not be saved.')) {
            clearInterval(timerInterval);
            window.history.back();
        }
    }

    // Prevent accidental page refresh
    window.addEventListener('beforeunload', (e) => {
        if (timeLeft > 0 && timeLeft < 600) {
            e.preventDefault();
            e.returnValue = '';
        }
    });

    // Start timer when page loads
    window.addEventListener('load', () => {
        startTimer();
    });

    // Disable right-click and copy (optional anti-cheating measure)
    document.addEventListener('contextmenu', (e) => e.preventDefault());
    document.addEventListener('copy', (e) => e.preventDefault());
</script>

