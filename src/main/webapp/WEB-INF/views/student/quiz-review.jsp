<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.ejbs.QuizSessionBean" %>
<%@ page import="com.htetaung.lms.models.dto.QuizIndividualQuestionDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    QuizSessionBean quizSession = (QuizSessionBean) request.getAttribute("quizSession");
    if (quizSession == null) {
        quizSession = (QuizSessionBean) session.getAttribute("quizSession");
    }

    if (quizSession == null || !quizSession.isQuizInitialized()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
        return;
    }

    List<QuizIndividualQuestionDTO> allQuestions = quizSession.getAllQuestions();
    Map<Long, Integer> allAnswers = quizSession.getAllAnswers();
    String contextPath = request.getContextPath();

    int totalQuestions = quizSession.getTotalQuestionsCount();
    int answeredCount = quizSession.getAnsweredQuestionsCount();
    boolean canSubmit = quizSession.areAllQuestionsAnswered();
    long elapsedTime = quizSession.getElapsedTimeInSeconds();
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Review Quiz - APU LMS</title>
    <link rel="icon" type="image/jpg" href="<%= contextPath %>/images/logos/logo_apu.jpg"/>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-base-200">

<div class="container mx-auto p-6 max-w-6xl">
    <!-- Header -->
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">Review Your Answers</h1>
        <p class="text-base-content/70">Check your answers before final submission</p>
    </div>

    <!-- Summary Card -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <h2 class="card-title mb-4">Quiz Summary</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="stat bg-base-200 rounded-lg p-4">
                    <div class="stat-title">Total Questions</div>
                    <div class="stat-value text-2xl"><%= totalQuestions %></div>
                </div>
                <div class="stat <%= canSubmit ? "bg-success/10" : "bg-warning/10" %> rounded-lg p-4">
                    <div class="stat-title">Answered</div>
                    <div class="stat-value text-2xl <%= canSubmit ? "text-success" : "text-warning" %>">
                        <%= answeredCount %>
                    </div>
                </div>
                <div class="stat bg-info/10 rounded-lg p-4">
                    <div class="stat-title">Time Spent</div>
                    <div class="stat-value text-2xl text-info">
                        <%= String.format("%d:%02d", elapsedTime / 60, elapsedTime % 60) %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <% if (!canSubmit) { %>
    <!-- Warning if not all questions answered -->
    <div class="alert alert-warning mb-6">
        <img src="<%= contextPath %>/images/icons/warning.png"
             alt="Warning" class="w-6 h-6 shrink-0">
        <div>
            <h3 class="font-bold">Incomplete Quiz</h3>
            <p class="text-sm">You have <%= totalQuestions - answeredCount %> unanswered question(s).
               You must answer all questions before submitting.</p>
        </div>
    </div>
    <% } %>

    <!-- Questions Review -->
    <div class="space-y-4 mb-6">
        <%
        if (allQuestions != null) {
            for (int i = 0; i < allQuestions.size(); i++) {
                QuizIndividualQuestionDTO question = allQuestions.get(i);
                Integer selectedAnswer = allAnswers.get(question.getQuizQuestionId());
                boolean isAnswered = selectedAnswer != null;
                List<String> options = question.getOptions();
        %>
        <div class="card bg-base-100 shadow border <%= isAnswered ? "border-success/30" : "border-warning" %>">
            <div class="card-body p-4">
                <div class="flex items-start justify-between mb-3">
                    <h3 class="font-bold text-lg">Question <%= i + 1 %></h3>
                    <% if (isAnswered) { %>
                    <div class="badge badge-success">Answered</div>
                    <% } else { %>
                    <div class="badge badge-warning">Not Answered</div>
                    <% } %>
                </div>

                <p class="text-base-content mb-4"><%= question.getQuestionText() %></p>

                <% if (options != null) { %>
                <div class="space-y-2">
                    <% for (int j = 0; j < options.size(); j++) {
                        boolean isSelected = isAnswered && selectedAnswer == j;
                    %>
                    <div class="flex items-start gap-2 p-3 rounded-lg <%= isSelected ? "bg-primary/10 border-2 border-primary" : "bg-base-200" %>">
                        <span class="font-semibold <%= isSelected ? "text-primary" : "" %>">
                            <%= (char)('A' + j) %>.
                        </span>
                        <span class="flex-1 <%= isSelected ? "font-semibold text-primary" : "" %>">
                            <%= options.get(j) %>
                        </span>
                        <% if (isSelected) { %>
                        <span class="badge badge-primary badge-sm">Your Answer</span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <!-- Edit Button -->
                <div class="card-actions justify-end mt-4">
                    <form method="get" action="<%= contextPath %>/api/take-quiz">
                        <input type="hidden" name="assessmentId" value="<%= quizSession.getAssessmentId() %>">
                        <input type="hidden" name="action" value="goto">
                        <input type="hidden" name="questionIndex" value="<%= i %>">
                        <button type="submit" class="btn btn-sm btn-outline">
                            <img src="<%= contextPath %>/images/icons/pencil-edit.png"
                                 alt="Edit" class="h-4 w-4 mr-1">
                            <%= isAnswered ? "Change Answer" : "Answer Question" %>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        <%
            }
        }
        %>
    </div>

    <!-- Action Buttons -->
    <div class="flex justify-between items-center gap-4">
        <a href="<%= contextPath %>/api/take-quiz?assessmentId=<%= quizSession.getAssessmentId() %>&action=goto&questionIndex=<%= totalQuestions - 1 %>"
           class="btn btn-outline">
            <img src="<%= contextPath %>/images/icons/arrow-right.png"
                 alt="Back" class="h-5 w-5 rotate-180">
            Back to Quiz
        </a>

        <% if (canSubmit) { %>
        <button class="btn btn-success btn-lg" onclick="confirmSubmission()">
            Submit Quiz
            <img src="<%= contextPath %>/images/icons/upload.png"
                 alt="Submit" class="h-5 w-5 ml-2">
        </button>
        <% } else { %>
        <button class="btn btn-disabled btn-lg" disabled>
            Submit Quiz (Answer All Questions)
        </button>
        <% } %>
    </div>
</div>

<!-- Confirmation Modal -->
<dialog id="submit_confirmation_modal" class="modal">
    <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">Confirm Quiz Submission</h3>
        <p class="mb-4">Are you sure you want to submit this quiz? Once submitted, you cannot change your answers.</p>

        <div class="bg-info/10 rounded-lg p-4 mb-4">
            <p class="text-sm">
                <strong>Total Questions:</strong> <%= totalQuestions %><br>
                <strong>Answered:</strong> <%= answeredCount %><br>
                <strong>Time Spent:</strong> <%= String.format("%d minutes %d seconds", elapsedTime / 60, elapsedTime % 60) %>
            </p>
        </div>

        <div class="modal-action">
            <form method="dialog">
                <button class="btn btn-ghost">Cancel</button>
            </form>
            <form method="post" action="<%= contextPath %>/api/take-quiz">
                <input type="hidden" name="action" value="submit">
                <input type="hidden" name="assessmentId" value="<%= quizSession.getAssessmentId() %>">
                <button type="submit" class="btn btn-success">
                    Confirm Submission
                </button>
            </form>
        </div>
    </div>
    <form method="dialog" class="modal-backdrop">
        <button>close</button>
    </form>
</dialog>

<script>
function confirmSubmission() {
    document.getElementById('submit_confirmation_modal').showModal();
}

// Prevent accidental page leave
window.addEventListener('beforeunload', function (e) {
    e.preventDefault();
    e.returnValue = '';
});
</script>

</body>
</html>
