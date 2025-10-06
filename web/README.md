# MusNote - Multilingual Music Learning Platform

A responsive, SEO-optimized website for learning music theory and piano with support for multiple languages (English, Russian, German).

## 🌟 Features

- **Multilingual Support**: English (default), Russian, German
- **Responsive Design**: Mobile-first approach with adaptive layouts
- **SEO Optimized**: Meta tags, structured data, sitemap, robots.txt
- **Performance Optimized**: Lazy loading, compression, caching
- **Accessibility**: ARIA labels, keyboard navigation, focus management
- **Markdown Articles**: Easy content management with multilingual articles

## 📁 Project Structure

```
web/
├── index.html                 # English homepage
├── ru/
│   └── index.html            # Russian homepage
├── de/
│   └── index.html            # German homepage
├── assets/
│   ├── css/
│   │   ├── main.css          # Main styles
│   │   └── responsive.css     # Responsive styles
│   ├── js/
│   │   ├── main.js           # Main application logic
│   │   └── language.js       # Language management
│   ├── images/               # Images and icons
│   ├── fonts/                # Web fonts
│   ├── translations/
│   │   └── translations.json # Translation strings
│   └── data/
│       └── articles.json     # Articles metadata
├── content/
│   └── articles/
│       ├── en/               # English articles (Markdown)
│       ├── ru/               # Russian articles (Markdown)
│       └── de/               # German articles (Markdown)
├── sitemap.xml               # SEO sitemap
├── robots.txt               # Search engine directives
└── .htaccess                # Apache configuration
```

## 🚀 Getting Started

### Prerequisites
- Web server (Apache, Nginx, or any static file server)
- Modern web browser

### Installation

1. **Clone or download the project**
   ```bash
   git clone <repository-url>
   cd musnote.com/web
   ```

2. **Configure your web server**
   - Point your web server to the `web/` directory
   - Ensure `.htaccess` is supported (for Apache)
   - Configure SSL certificate for HTTPS

3. **Customize content**
   - Update translations in `assets/translations/translations.json`
   - Add your articles in `content/articles/[lang]/`
   - Replace placeholder images in `assets/images/`

## 🌐 Language Support

### URL Structure
- English (default): `https://musnote.com/`
- Russian: `https://musnote.com/ru/`
- German: `https://musnote.com/de/`

### Adding New Languages

1. **Create language directory**
   ```bash
   mkdir -p web/[lang]/
   ```

2. **Add language homepage**
   - Copy `index.html` to `[lang]/index.html`
   - Update `lang` attribute and content
   - Add language to selector

3. **Update translations**
   - Add language to `translations.json`
   - Update `language.js` language detection

4. **Update SEO files**
   - Add to `sitemap.xml`
   - Update `robots.txt` if needed

## 📝 Content Management

### Adding Articles

1. **Create Markdown file**
   ```bash
   touch content/articles/[lang]/article-slug.md
   ```

2. **Add frontmatter**
   ```yaml
   ---
   title: "Article Title"
   excerpt: "Brief description"
   date: "2024-01-15"
   category: "Category"
   image: "/assets/images/articles/image.jpg"
   lang: "en"
   slug: "article-slug"
   ---
   ```

3. **Update articles.json**
   - Add article metadata to `assets/data/articles.json`
   - Include all language versions

### Article Structure
- **Frontmatter**: YAML metadata
- **Content**: Markdown format
- **Images**: Store in `assets/images/articles/`
- **Multilingual**: Create separate files for each language

## 🎨 Customization

### Styling
- **Main styles**: `assets/css/main.css`
- **Responsive**: `assets/css/responsive.css`
- **Variables**: CSS custom properties for easy theming

### JavaScript
- **Main app**: `assets/js/main.js`
- **Language**: `assets/js/language.js`
- **Modular**: Easy to extend and customize

### SEO
- **Meta tags**: Automatic generation based on language
- **Structured data**: JSON-LD for rich snippets
- **Sitemap**: Auto-generated multilingual sitemap
- **Robots**: Search engine directives

## 🔧 Configuration

### Apache (.htaccess)
- **HTTPS redirect**: Automatic SSL enforcement
- **Language detection**: Browser language detection
- **Caching**: Optimized cache headers
- **Compression**: Gzip compression enabled
- **Security**: Security headers included

### Performance
- **Lazy loading**: Images load on demand
- **Preloading**: Critical resources preloaded
- **Compression**: Gzip compression
- **Caching**: Browser and server caching

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 768px
- **Tablet**: 768px - 1199px
- **Desktop**: ≥ 1200px

### Features
- **Mobile menu**: Hamburger navigation
- **Touch friendly**: Large touch targets
- **Optimized images**: Responsive images
- **Fast loading**: Optimized for mobile

## ♿ Accessibility

### Features
- **ARIA labels**: Screen reader support
- **Keyboard navigation**: Full keyboard support
- **Focus management**: Visible focus indicators
- **Color contrast**: WCAG compliant colors
- **Semantic HTML**: Proper heading structure

## 🔍 SEO Features

### Technical SEO
- **Meta tags**: Title, description, keywords
- **Open Graph**: Social media sharing
- **Twitter Cards**: Twitter sharing
- **Canonical URLs**: Duplicate content prevention
- **Hreflang**: Language targeting
- **Structured data**: Rich snippets

### Content SEO
- **Semantic HTML**: Proper heading hierarchy
- **Alt text**: Image descriptions
- **Internal linking**: Related content links
- **URL structure**: Clean, descriptive URLs

## 🚀 Deployment

### Static Hosting
- **GitHub Pages**: Direct deployment
- **Netlify**: Automatic builds
- **Vercel**: Edge deployment
- **AWS S3**: Static website hosting

### Server Requirements
- **Apache**: With mod_rewrite enabled
- **Nginx**: With proper configuration
- **PHP**: Not required (static site)
- **SSL**: HTTPS certificate required

## 📊 Analytics

### Google Analytics
- Add tracking code to `index.html`
- Configure goals and events
- Monitor multilingual traffic

### Search Console
- Submit sitemap: `https://musnote.com/sitemap.xml`
- Monitor search performance
- Track international targeting

## 🛠️ Development

### Local Development
```bash
# Using Python
python -m http.server 8000

# Using Node.js
npx serve .

# Using PHP
php -S localhost:8000
```

### Testing
- **Cross-browser**: Test in multiple browsers
- **Mobile**: Test on real devices
- **Accessibility**: Use screen readers
- **Performance**: Use Lighthouse

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For questions or support, please open an issue in the repository.

---

**MusNote** - Learn music theory with confidence! 🎵
