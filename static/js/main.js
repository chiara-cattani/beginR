// Main JavaScript for ClinicalRTransition

document.addEventListener('DOMContentLoaded', function() {
    // Update current date in footer
    updateCurrentDate();

    // Theme Toggle Functionality
    const themeToggle = document.getElementById('themeToggle');
    const lightIcon = document.getElementById('lightIcon');
    const darkIcon = document.getElementById('darkIcon');
    const html = document.documentElement;

    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('theme') || 'light';
    html.setAttribute('data-bs-theme', savedTheme);
    updateThemeIcon(savedTheme);

    // Theme toggle event listener
    if (themeToggle) {
        themeToggle.addEventListener('click', function() {
            const currentTheme = html.getAttribute('data-bs-theme');
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';

            html.setAttribute('data-bs-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            updateThemeIcon(newTheme);

            // Send theme change to server (optional)
            fetch('/toggle_theme', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ theme: newTheme })
            });
        });
    }

    function updateThemeIcon(theme) {
        if (theme === 'light') {
            // Show moon icon in light mode (clicking will switch to dark)
            lightIcon.style.display = 'none';
            darkIcon.style.display = 'inline-block';
        } else {
            // Show sun icon in dark mode (clicking will switch to light)
            lightIcon.style.display = 'inline-block';
            darkIcon.style.display = 'none';
        }
    }

    // Music Player Functionality
    const musicToggle = document.getElementById('musicToggle');
    const musicIcon = document.getElementById('musicIcon');

    // YouTube links configuration
    const youtubeLinks = {
        house: 'https://www.youtube.com/watch?v=MJbb82S6FBo',
        piano: 'https://www.youtube.com/watch?v=MiaPRJw-bFo',
        organic: 'https://www.youtube.com/watch?v=sWOrd50HYa4&list=RDsWOrd50HYa4&start_radio=1&t=3354s',
        natural: 'https://www.youtube.com/watch?v=uwEaQk5VeS4&t=1131s',
        jazz: 'https://www.youtube.com/watch?v=Dx5qFachd3A'
    };

    // Load saved genre preference
    let currentGenre = localStorage.getItem('musicGenre') || 'organic';

    // Update button title with current genre
    if (musicToggle) {
        musicToggle.title = `Choose music genre`;
    }

    // Genre selection handlers
    document.querySelectorAll('[data-genre]').forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            const genre = this.dataset.genre;

            // Open YouTube link in new tab
            if (youtubeLinks[genre]) {
                window.open(youtubeLinks[genre], '_blank');
            }

            // Update current genre for display purposes
            currentGenre = genre;
            localStorage.setItem('musicGenre', genre);
        });
    });



    // Progress Tracking
    const progressCheckboxes = document.querySelectorAll('.progress-checkbox');
    progressCheckboxes.forEach(checkbox => {
        // Load saved progress
        const moduleId = checkbox.dataset.moduleId;
        const itemId = checkbox.dataset.itemId;
        const savedProgress = localStorage.getItem(`progress_${moduleId}_${itemId}`);
        if (savedProgress === 'true') {
            checkbox.checked = true;
            updateProgressUI(checkbox);
        }
        checkbox.addEventListener('change', function() {
            localStorage.setItem(`progress_${moduleId}_${itemId}`, this.checked);
            updateProgressUI(this);

            // Update recent activity and overall progress
            updateRecentActivity();
            updateOverallProgress();
            checkCertificateEligibility();
        });
    });

    function updateProgressUI(checkbox) {
        const progressItem = checkbox.closest('.progress-item');
        if (checkbox.checked) {
            progressItem.classList.add('completed');
            progressItem.style.opacity = '0.7';
        } else {
            progressItem.classList.remove('completed');
            progressItem.style.opacity = '1';
        }
        // Update module progress bar
        updateModuleProgress(checkbox.dataset.moduleId);
    }

    function updateModuleProgress(moduleId) {
        const moduleCheckboxes = document.querySelectorAll(`[data-module-id="${moduleId}"]`);
        if (moduleCheckboxes.length === 0) return;
        const checkedBoxes = Array.from(moduleCheckboxes).filter(cb => cb.checked);
        const progressPercentage = (checkedBoxes.length / moduleCheckboxes.length) * 100;
        const progressBar = document.querySelector(`[data-progress-bar="${moduleId}"]`);
        if (progressBar) {
            progressBar.style.width = `${progressPercentage}%`;
            progressBar.setAttribute('aria-valuenow', progressPercentage);
        }
    }

    // --- Overall Progress (Modules Page) ---
    function updateOverallProgress() {
        // Calculate progress from localStorage
        let totalObjectives = 0;
        let completedObjectives = 0;

        // Count total objectives and completed ones from localStorage
        for (let moduleId = 1; moduleId <= 7; moduleId++) {
            const moduleKeys = Object.keys(localStorage).filter(key => key.startsWith(`progress_${moduleId}_`));
            totalObjectives += moduleKeys.length;
            completedObjectives += moduleKeys.filter(key => localStorage.getItem(key) === 'true').length;
        }

        const percent = totalObjectives > 0 ? Math.round((completedObjectives / totalObjectives) * 100) : 0;
        const overallBar = document.getElementById('overallProgress');
        if (overallBar) {
            overallBar.style.width = percent + '%';
            overallBar.setAttribute('aria-valuenow', percent);
        }

        // Update text (total should be 35 objectives across all modules)
        const progressText = document.getElementById('overallProgressText');
        if (progressText) {
            progressText.textContent = `${completedObjectives} of 35 objectives completed`;
        }
    }

    // --- Recent Activity (Modules Page) ---
    function updateRecentActivity() {
        const recentDiv = document.getElementById('recentActivity');
        if (!recentDiv) return;

        // Check if ALL modules are truly completed (using the same logic as course completion)
        let allModulesCompleted = true;
        let nextModuleId = null;
        let nextModuleTitle = null;

        for (let moduleId = 1; moduleId <= 7; moduleId++) {
            const moduleKeys = Object.keys(localStorage).filter(key => key.startsWith(`progress_${moduleId}_`));
            const completedObjectives = moduleKeys.filter(key => localStorage.getItem(key) === 'true').length;

            // If no progress exists for this module OR not all objectives completed
            if (moduleKeys.length === 0 || completedObjectives < moduleKeys.length) {
                allModulesCompleted = false;

                // Set this as the next module to work on (if we haven't found one yet)
                if (!nextModuleId) {
                    nextModuleId = moduleId;
                    // Get module title from the page or use fallback
                    const moduleCard = document.querySelector(`[data-module-id="${moduleId}"]`);
                    if (moduleCard) {
                        const titleElement = moduleCard.querySelector('.card-title');
                        nextModuleTitle = titleElement ? titleElement.textContent : `Module ${moduleId}`;
                    } else {
                        nextModuleTitle = `Module ${moduleId}`;
                    }
                }
            }
        }

        if (!allModulesCompleted && nextModuleId) {
            // Show next module to continue
            recentDiv.innerHTML = `
                <div class="list-group-item border-0 px-0">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-play-circle text-primary me-3"></i>
                        <div>
                            <h6 class="mb-1"><a href="/module/${nextModuleId}" class="text-decoration-none">Continue: ${nextModuleTitle}</a></h6>
                            <p class="text-muted small mb-0">Resume your learning journey</p>
                        </div>
                    </div>
                </div>`;
        } else if (allModulesCompleted) {
            // All modules truly completed
            recentDiv.innerHTML = `
                <div class="list-group-item border-0 px-0">
                    <div class="flex-grow-1">
                        <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-trophy text-warning me-2"></i>
                            <h6 class="mb-0 text-warning">Congratulations!</h6>
                        </div>
                        <p class="text-muted small mb-2">All modules completed. Download your certificate!</p>
                        <div class="simple-star-rating mt-2">
                            <i class="fas fa-star" data-rating="1"></i>
                            <i class="fas fa-star" data-rating="2"></i>
                            <i class="fas fa-star" data-rating="3"></i>
                            <i class="fas fa-star" data-rating="4"></i>
                            <i class="fas fa-star" data-rating="5"></i>
                        </div>
                        <div class="feedback-text-container mt-2" style="display: none;">
                            <textarea class="form-control form-control-sm" id="feedbackText"
                                placeholder="Leave a feedback..." rows="2" maxlength="500"></textarea>
                            <button class="btn btn-sm btn-primary mt-2" id="submitFeedbackBtn">
                                <i class="fas fa-paper-plane me-1"></i>Submit Feedback
                            </button>
                        </div>
                    </div>
                </div>`;

            // Initialize simple star rating
            initializeSimpleStarRating();
        } else {
            // Fallback case (shouldn't happen with the new logic)
            recentDiv.innerHTML = `
                <div class="list-group-item border-0 px-0">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-play-circle text-primary me-3"></i>
                        <div>
                            <h6 class="mb-1"><a href="/module/1" class="text-decoration-none">Ready to start!</a></h6>
                            <p class="text-muted small mb-0">Begin with Module 1: Getting Started with R</p>
                        </div>
                    </div>
                </div>`;
        }
    }

    // --- Certificate Eligibility ---
    function checkCertificateEligibility() {
        let allCompleted = true;

        for (let moduleId = 1; moduleId <= 7; moduleId++) {
            const moduleKeys = Object.keys(localStorage).filter(key => key.startsWith(`progress_${moduleId}_`));
            const completedObjectives = moduleKeys.filter(key => localStorage.getItem(key) === 'true').length;

            // If no progress exists for this module OR not all objectives completed
            if (moduleKeys.length === 0 || completedObjectives < moduleKeys.length) {
                allCompleted = false;
                break;
            }
        }

        const certBtn = document.getElementById('downloadCertificateBtn');
        if (certBtn) {
            certBtn.style.display = allCompleted ? 'inline-block' : 'none';
        }
        // Certificate form display logic removed - now using direct download
    }

    // --- Helper: Get Module Title (for recent activity) ---
    function getModuleTitle(moduleId) {
        // Try to get from DOM, fallback to generic
        const card = document.querySelector(`.module-card[data-module-id="${moduleId}"]`);
        if (card) {
            const title = card.querySelector('.card-title');
            if (title) return title.textContent;
        }
        // Fallback
        return `Module ${moduleId}`;
    }

    // On modules page, update recent activity and overall progress
    updateRecentActivity();
    updateOverallProgress();
    checkCertificateEligibility();

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });

    // Download button loading states
    document.querySelectorAll('.download-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const originalText = this.innerHTML;
            this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Downloading...';
            this.classList.add('loading');

            // Reset after a delay (simulating download)
            setTimeout(() => {
                this.innerHTML = originalText;
                this.classList.remove('loading');
            }, 2000);
        });
    });

    // Module card hover effects
    document.querySelectorAll('.module-card').forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px)';
        });

        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
        });
    });

    // Animate elements on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in-up');
            }
        });
    }, observerOptions);

    // Observe all cards and sections
    document.querySelectorAll('.card, .hero-section, .feature-section').forEach(el => {
        observer.observe(el);
    });

    // Search functionality (if implemented)
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const moduleCards = document.querySelectorAll('.module-card');

            moduleCards.forEach(card => {
                const title = card.querySelector('.card-title').textContent.toLowerCase();
                const description = card.querySelector('.card-text').textContent.toLowerCase();

                if (title.includes(searchTerm) || description.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        });
    }

    // Copy to clipboard functionality
    document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            const codeBlock = this.closest('.code-block').querySelector('code');
            const textToCopy = codeBlock.textContent;

            navigator.clipboard.writeText(textToCopy).then(() => {
                const originalText = this.innerHTML;
                this.innerHTML = '<i class="fas fa-check"></i> Copied!';
                this.classList.add('btn-success');

                setTimeout(() => {
                    this.innerHTML = originalText;
                    this.classList.remove('btn-success');
                }, 2000);
            });
        });
    });

    // Tooltip initialization
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Toast notifications
    function showToast(message, type = 'info') {
        const toastContainer = document.getElementById('toastContainer');
        if (!toastContainer) return;

        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type} border-0`;
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');

        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        `;

        toastContainer.appendChild(toast);
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();

        // Remove toast after it's hidden
        toast.addEventListener('hidden.bs.toast', () => {
            toast.remove();
        });
    }

    // Global toast function
    window.showToast = showToast;

    // Keyboard shortcuts
    document.addEventListener('keydown', function(e) {
        // Ctrl/Cmd + K for search
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.focus();
            }
        }

        // Ctrl/Cmd + D for theme toggle
        if ((e.ctrlKey || e.metaKey) && e.key === 'd') {
            e.preventDefault();
            if (themeToggle) {
                themeToggle.click();
            }
        }
    });

    // Initialize any additional components
    console.log('ClinicalRTransition app initialized successfully!');
});

// Function to update current date in footer
function updateCurrentDate() {
    const currentDateElement = document.getElementById('current-date');
    if (currentDateElement) {
        const today = new Date();
        const options = {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        };
        const formattedDate = today.toLocaleDateString('en-US', options);
        currentDateElement.textContent = formattedDate;
    }

    // Update seasonal icon
    updateSeasonalIcon();
}

function updateSeasonalIcon() {
    const seasonalIconElement = document.getElementById('seasonal-icon');
    if (seasonalIconElement) {
        const today = new Date();
        const month = today.getMonth(); // 0-11

        let iconClass = '';
        let title = '';

        // Determine season based on month
        if (month === 11 || month === 0 || month === 1) {
            // Winter: December, January, February
            iconClass = 'fas fa-snowflake';
            title = 'Winter';
        } else if (month >= 2 && month <= 4) {
            // Spring: March, April, May
            iconClass = 'fas fa-seedling';
            title = 'Spring';
        } else if (month >= 5 && month <= 7) {
            // Summer: June, July, August
            iconClass = 'fas fa-sun';
            title = 'Summer';
        } else {
            // Autumn: September, October, November
            iconClass = 'fas fa-leaf';
            title = 'Autumn';
        }

        seasonalIconElement.className = iconClass + ' me-1';
        seasonalIconElement.title = title;
    }
}

// Simple Star Rating System
function initializeSimpleStarRating() {
    const starRating = document.querySelector('.simple-star-rating');
    let selectedRating = 0;

    if (starRating) {
        const stars = starRating.querySelectorAll('i');
        const feedbackContainer = document.querySelector('.feedback-text-container');
        const submitBtn = document.getElementById('submitFeedbackBtn');

        stars.forEach((star, index) => {
            star.addEventListener('click', function() {
                selectedRating = index + 1;

                // Update star appearance
                stars.forEach((s, i) => {
                    if (i < selectedRating) {
                        s.classList.add('selected');
                    } else {
                        s.classList.remove('selected');
                    }
                });

                // Automatically save rating when star is clicked
                submitSimpleRating(selectedRating, '');

                // Show feedback text container for optional comment
                if (feedbackContainer) {
                    feedbackContainer.style.display = 'block';
                }
            });

            star.addEventListener('mouseover', function() {
                const rating = index + 1;
                stars.forEach((s, i) => {
                    if (i < rating) {
                        s.style.color = '#ffc107';
                    } else {
                        s.style.color = '#ddd';
                    }
                });
            });
        });

        starRating.addEventListener('mouseleave', function() {
            // Reset to selected state
            stars.forEach((s, i) => {
                if (s.classList.contains('selected')) {
                    s.style.color = '#ffc107';
                } else {
                    s.style.color = '#ddd';
                }
            });
        });

        // Handle submit feedback button (for text feedback only)
        if (submitBtn) {
            submitBtn.addEventListener('click', function() {
                const feedbackText = document.getElementById('feedbackText').value.trim();
                if (feedbackText && selectedRating > 0) {
                    // Update the existing rating with feedback text
                    submitSimpleRating(selectedRating, feedbackText, true);
                }
            });
        }
    }
}

function submitSimpleRating(rating, feedbackText = '', isTextUpdate = false) {
    // Store rating data
    const timestamp = new Date().toISOString();
    const ratingData = {
        rating: rating,
        feedback: feedbackText,
        timestamp: timestamp,
        isUpdate: isTextUpdate
    };

    // Submit to server
    fetch('/submit_simple_rating', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(ratingData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            console.log('Rating submitted successfully');

            if (isTextUpdate) {
                // Show success message for text feedback
                const feedbackContainer = document.querySelector('.feedback-text-container');
                if (feedbackContainer) {
                    feedbackContainer.innerHTML = '<small class="text-success"><i class="fas fa-check me-1"></i>Thank you for your feedback!</small>';
                    setTimeout(() => {
                        feedbackContainer.style.display = 'none';
                    }, 3000);
                }
            } else if (!feedbackText) {
                // Just show a brief confirmation for star rating
                console.log('Star rating saved automatically');
            }
        } else {
            console.error('Error submitting rating:', data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
}
