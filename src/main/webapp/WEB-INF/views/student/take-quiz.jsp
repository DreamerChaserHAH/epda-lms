<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.htetaung.lms.ejbs.QuizSessionBean" %>
<%@ page import="com.htetaung.lms.models.dto.QuizIndividualQuestionDTO" %>
<%@ page import="com.htetaung.lms.models.dto.AssessmentDTO" %>
<%@ page import="java.util.List" %>
<%
    QuizSessionBean quizSession = (QuizSessionBean) session.getAttribute("quizSession");
    if (quizSession == null || !quizSession.isQuizInitialized()) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?page=assignments");
        return;
    }

    QuizIndividualQuestionDTO currentQuestion = quizSession.getCurrentQuestion();
    Integer currentAnswer = quizSession.getAnswerForCurrentQuestion();
    AssessmentDTO assessment = (AssessmentDTO) request.getAttribute("assessment");

    String contextPath = request.getContextPath();
    int currentQuestionNumber = quizSession.getCurrentQuestionNumber();
    int totalQuestions = quizSession.getTotalQuestionsCount();
    int answeredCount = quizSession.getAnsweredQuestionsCount();
    double progress = quizSession.getProgressPercentage();
%>
<!DOCTYPE html>
<html lang="en" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Take Quiz - APU LMS</title>
    <link rel="icon" type="image/jpg" href="<%= contextPath %>/images/logos/logo_apu.jpg"/>
    <link href="https://cdn.jsdelivr.net/npm/daisyui@5" rel="stylesheet" type="text/css" />
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="min-h-screen bg-base-200">

<div class="container mx-auto p-6 max-w-4xl">
    <!-- Header -->
    <div class="mb-6">
        <h1 class="text-3xl font-bold text-base-content mb-2">
            <%= assessment != null ? assessment.getAssessmentName() : "Quiz" %>
        </h1>
        <p class="text-base-content/70">Answer all questions to complete the quiz</p>
    </div>

    <!-- Progress Bar -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body p-4">
            <div class="flex justify-between items-center mb-2">
                <span class="text-sm font-semibold">Progress</span>
                <span class="text-sm text-base-content/70">
                    <%= answeredCount %> / <%= totalQuestions %> answered
                </span>
            </div>
            <progress class="progress progress-primary w-full"
                      value="<%= progress %>" max="100"></progress>
            <p class="text-xs text-base-content/60 mt-1">
                <%= String.format("%.0f", progress) %>% complete
            </p>
        </div>
    </div>

    <% if (currentQuestion != null) { %>
    <!-- Question Card -->
    <div class="card bg-base-100 shadow-xl border border-base-300 mb-6">
        <div class="card-body">
            <!-- Question Number -->
            <div class="flex items-center justify-between mb-4">
                <div class="badge badge-primary badge-lg">
                    Question <%= currentQuestionNumber %> of <%= totalQuestions %>
                </div>
                <% if (quizSession.isQuestionAnswered(quizSession.getCurrentQuestionIndex())) { %>
                <div class="badge badge-success">Answered</div>
                <% } else { %>
                <div class="badge badge-warning">Not Answered</div>
                <% } %>
            </div>

            <!-- Question Text -->
            <h2 class="text-xl font-bold text-base-content mb-6">
                <%= currentQuestion.getQuestionText() %>
            </h2>

            <!-- Answer Options -->
            <form method="get" action="<%= contextPath %>/api/take-quiz" id="quizForm">
                <input type="hidden" name="assessmentId" value="<%= quizSession.getAssessmentId() %>">
                <input type="hidden" name="action" id="formAction" value="next">

                <div class="space-y-3">
                    <%
                        List<String> options = currentQuestion.getOptions();
                        if (options != null) {
                            for (int i = 0; i < options.size(); i++) {
                                boolean isSelected = currentAnswer != null && currentAnswer == i;
                    %>
                    <label class="flex items-start gap-3 p-4 border-2 rounded-lg cursor-pointer transition-all
                                  <%= isSelected ? "border-primary bg-primary/10" : "border-base-300 hover:border-primary/50" %>">
                        <input type="radio"
                               name="selectedOption"
                               value="<%= i %>"
                               class="radio radio-primary mt-1"
                               <%= isSelected ? "checked" : "" %>>
                        <span class="flex-1 text-base-content">
                            <span class="font-semibold mr-2">Option <%= (char)('A' + i) %>:</span>
                            <%= options.get(i) %>
                        </span>
                    </label>
                    <%
                            }
                        }
                    %>
                </div>
            </form>
        </div>
    </div>

    <!-- Navigation Buttons -->
    <div class="flex justify-between items-center gap-4">
        <!-- Previous Button -->
        <% if (quizSession.hasPreviousQuestion()) { %>
        <button class="btn btn-outline" onclick="navigateQuiz('previous')">
            <img src="<%= contextPath %>/images/icons/arrow-right.png"
                 alt="Previous" class="h-5 w-5 rotate-180">
            Previous
        </button>
        <% } else { %>
        <div></div>
        <% } %>

        <!-- Question Navigator -->
        <div class="flex gap-2 flex-wrap justify-center">
            <% for (int i = 0; i < totalQuestions; i++) {
                boolean isAnswered = quizSession.isQuestionAnswered(i);
                boolean isCurrent = i == quizSession.getCurrentQuestionIndex();
                String btnClass = isCurrent ? "btn-primary" : (isAnswered ? "btn-success" : "btn-outline");
            %>
            <button class="btn btn-sm <%= btnClass %>"
                    onclick="navigateToQuestion(<%= i %>)"
                    title="Question <%= i + 1 %>">
                <%= i + 1 %>
            </button>
            <% } %>
        </div>

        <!-- Next/Review Button -->
        <% if (quizSession.hasNextQuestion()) { %>
        <button class="btn btn-primary" onclick="navigateQuiz('next')">
            Next
            <img src="<%= contextPath %>/images/icons/arrow-right.png"
                 alt="Next" class="h-5 w-5">
        </button>
        <% } else { %>
        <button class="btn btn-success" onclick="navigateQuiz('review')">
            Review & Submit
        </button>
        <% } %>
    </div>

    <!-- Warning if not all answered -->
    <% if (!quizSession.areAllQuestionsAnswered()) { %>
    <div class="alert alert-warning mt-6">
        <img src="<%= contextPath %>/images/icons/warning.png"
             alt="Warning" class="w-6 h-6 shrink-0">
        <div>
            <h3 class="font-bold">Incomplete Quiz</h3>
            <p class="text-sm">You have <%= totalQuestions - answeredCount %> unanswered question(s).
               Please answer all questions before submitting.</p>
        </div>
    </div>
    <% } %>
    <% } %>
</div>

<script>
function navigateQuiz(action) {
    document.getElementById('formAction').value = action;
    document.getElementById('quizForm').submit();
}

function navigateToQuestion(index) {
    document.getElementById('formAction').value = 'goto';
    const form = document.getElementById('quizForm');

    // Add question index parameter
    let input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'questionIndex';
    input.value = index;
    form.appendChild(input);

    form.submit();
}

// Auto-save answer when option is selected
document.querySelectorAll('input[name="selectedOption"]').forEach(radio => {
    radio.addEventListener('change', function() {
        // Visual feedback that answer is saved
        const label = this.closest('label');
        label.classList.add('border-primary', 'bg-primary/10');
    });
});

// Warn before leaving page
window.addEventListener('beforeunload', function (e) {
    e.preventDefault();
    e.returnValue = '';
});
</script>

<style>
@media print {
    .btn, .alert-warning {
        display: none;
    }
}
</style>

</body>
</html>
