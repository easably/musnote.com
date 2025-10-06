// Language management system
class LanguageManager {
    constructor() {
        this.currentLanguage = this.getCurrentLanguage();
        this.translations = {};
        this.init();
    }

    init() {
        this.loadTranslations();
        this.setupLanguageSelector();
        this.applyTranslations();
    }

    getCurrentLanguage() {
        // Check URL path first
        const path = window.location.pathname;
        if (path.startsWith('/ru/')) return 'ru';
        if (path.startsWith('/de/')) return 'de';
        return 'en';
    }

    async loadTranslations() {
        try {
            const response = await fetch('/assets/translations/translations.json');
            this.translations = await response.json();
        } catch (error) {
            console.error('Failed to load translations:', error);
            // Fallback translations
            this.translations = {
                en: {
                    'nav.home': 'Home',
                    'nav.piano': 'Piano',
                    'nav.articles': 'Articles',
                    'nav.about': 'About',
                    'hero.title': 'Learn Music Theory with MusNote',
                    'hero.description': 'Master piano, understand chords, and explore the beautiful world of music theory with our interactive learning platform.',
                    'hero.start_learning': 'Start Learning',
                    'hero.read_articles': 'Read Articles',
                    'features.title': 'Why Choose MusNote?',
                    'features.interactive.title': 'Interactive Piano',
                    'features.interactive.description': 'Practice on our virtual piano with real-time feedback and note recognition.',
                    'features.theory.title': 'Music Theory',
                    'features.theory.description': 'Learn chords, scales, and music theory concepts with detailed explanations.',
                    'features.articles.title': 'Educational Articles',
                    'features.articles.description': 'Read comprehensive articles about music theory and piano techniques.',
                    'articles.recent': 'Recent Articles',
                    'articles.view_all': 'View All Articles',
                    'footer.about': 'About MusNote',
                    'footer.description': 'Your comprehensive platform for learning music theory and piano.',
                    'footer.links': 'Quick Links',
                    'footer.languages': 'Languages',
                    'footer.copyright': '© 2024 MusNote. All rights reserved.'
                },
                ru: {
                    'nav.home': 'Главная',
                    'nav.piano': 'Пианино',
                    'nav.articles': 'Статьи',
                    'nav.about': 'О нас',
                    'hero.title': 'Изучайте теорию музыки с MusNote',
                    'hero.description': 'Освойте пианино, изучите аккорды и исследуйте прекрасный мир теории музыки с нашей интерактивной платформой обучения.',
                    'hero.start_learning': 'Начать обучение',
                    'hero.read_articles': 'Читать статьи',
                    'features.title': 'Почему выбирают MusNote?',
                    'features.interactive.title': 'Интерактивное пианино',
                    'features.interactive.description': 'Практикуйтесь на нашем виртуальном пианино с обратной связью в реальном времени и распознаванием нот.',
                    'features.theory.title': 'Теория музыки',
                    'features.theory.description': 'Изучайте аккорды, гаммы и концепции теории музыки с подробными объяснениями.',
                    'features.articles.title': 'Образовательные статьи',
                    'features.articles.description': 'Читайте подробные статьи о теории музыки и техниках игры на пианино.',
                    'articles.recent': 'Последние статьи',
                    'articles.view_all': 'Все статьи',
                    'footer.about': 'О MusNote',
                    'footer.description': 'Ваша комплексная платформа для изучения теории музыки и пианино.',
                    'footer.links': 'Быстрые ссылки',
                    'footer.languages': 'Языки',
                    'footer.copyright': '© 2024 MusNote. Все права защищены.'
                },
                de: {
                    'nav.home': 'Startseite',
                    'nav.piano': 'Klavier',
                    'nav.articles': 'Artikel',
                    'nav.about': 'Über uns',
                    'hero.title': 'Lernen Sie Musiktheorie mit MusNote',
                    'hero.description': 'Meistern Sie das Klavier, verstehen Sie Akkorde und erkunden Sie die wunderschöne Welt der Musiktheorie mit unserer interaktiven Lernplattform.',
                    'hero.start_learning': 'Lernen beginnen',
                    'hero.read_articles': 'Artikel lesen',
                    'features.title': 'Warum MusNote wählen?',
                    'features.interactive.title': 'Interaktives Klavier',
                    'features.interactive.description': 'Üben Sie auf unserem virtuellen Klavier mit Echtzeit-Feedback und Notenerkennung.',
                    'features.theory.title': 'Musiktheorie',
                    'features.theory.description': 'Lernen Sie Akkorde, Skalen und Musiktheorie-Konzepte mit detaillierten Erklärungen.',
                    'features.articles.title': 'Bildungsartikel',
                    'features.articles.description': 'Lesen Sie umfassende Artikel über Musiktheorie und Klaviertechniken.',
                    'articles.recent': 'Neueste Artikel',
                    'articles.view_all': 'Alle Artikel anzeigen',
                    'footer.about': 'Über MusNote',
                    'footer.description': 'Ihre umfassende Plattform zum Lernen von Musiktheorie und Klavier.',
                    'footer.links': 'Schnelle Links',
                    'footer.languages': 'Sprachen',
                    'footer.copyright': '© 2024 MusNote. Alle Rechte vorbehalten.'
                }
            };
        }
    }

    setupLanguageSelector() {
        const selector = document.getElementById('language-selector');
        if (selector) {
            selector.value = this.currentLanguage;
            selector.addEventListener('change', (e) => {
                this.switchLanguage(e.target.value);
            });
        }
    }

    switchLanguage(language) {
        const currentPath = window.location.pathname;
        let newPath = currentPath;
        
        // Remove existing language prefix
        newPath = newPath.replace(/^\/ru\//, '/');
        newPath = newPath.replace(/^\/de\//, '/');
        
        // Add new language prefix if not English
        if (language !== 'en') {
            newPath = `/${language}${newPath}`;
        }
        
        // Ensure path starts with /
        if (!newPath.startsWith('/')) {
            newPath = '/' + newPath;
        }
        
        // Update URL
        window.location.href = newPath;
    }

    applyTranslations() {
        const elements = document.querySelectorAll('[data-translate]');
        elements.forEach(element => {
            const key = element.getAttribute('data-translate');
            const translation = this.getTranslation(key);
            if (translation) {
                element.textContent = translation;
            }
        });
    }

    getTranslation(key) {
        const language = this.currentLanguage;
        if (this.translations[language] && this.translations[language][key]) {
            return this.translations[language][key];
        }
        // Fallback to English
        if (this.translations.en && this.translations.en[key]) {
            return this.translations.en[key];
        }
        return key;
    }

    // Method to update page language without reload
    updateLanguage(language) {
        this.currentLanguage = language;
        this.applyTranslations();
        
        // Update document language
        document.documentElement.lang = language;
        
        // Update meta tags
        this.updateMetaTags(language);
    }

    updateMetaTags(language) {
        const titles = {
            en: 'MusNote - Music Learning Platform',
            ru: 'MusNote - Платформа для изучения музыки',
            de: 'MusNote - Musiklernplattform'
        };
        
        const descriptions = {
            en: 'Learn music theory, practice piano, and explore musical notes with MusNote - your comprehensive music learning platform.',
            ru: 'Изучайте теорию музыки, практикуйтесь на пианино и исследуйте музыкальные ноты с MusNote - вашей комплексной платформой для изучения музыки.',
            de: 'Lernen Sie Musiktheorie, üben Sie Klavier und erkunden Sie musikalische Noten mit MusNote - Ihrer umfassenden Musiklernplattform.'
        };

        document.title = titles[language] || titles.en;
        
        const metaDescription = document.querySelector('meta[name="description"]');
        if (metaDescription) {
            metaDescription.content = descriptions[language] || descriptions.en;
        }
    }
}

// Initialize language manager when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.languageManager = new LanguageManager();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LanguageManager;
}
