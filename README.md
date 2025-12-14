# DevAscent

Goldman Sachs Interview Preparation App - Low-Level Design & CS Fundamentals

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- Gemini API Key (for AI interviewer)

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/DevAscent.git
   cd DevAscent
   ```

2. **Configure API Key:**
   ```bash
   # Copy the secrets template
   cp DevAscent/Secrets.example.swift DevAscent/Secrets.swift
   ```
   
   Then edit `DevAscent/Secrets.swift` and add your Gemini API key:
   ```swift
   return "YOUR_ACTUAL_GEMINI_API_KEY"
   ```
   
   Get your key from: https://aistudio.google.com/app/apikey

3. **Open in Xcode:**
   ```bash
   open DevAscent.xcodeproj
   ```

4. **Build & Run** (⌘R)

## 📁 Project Structure

```
DevAscent/
├── Models/
│   ├── LLDProblem.swift
│   └── CSConcept.swift
├── Views/
│   ├── LLDTab/
│   ├── KernelTab/
│   └── ProfileTab/
├── Services/
│   ├── DataSeeder.swift        # Content coordinator
│   ├── GeminiService.swift     # AI integration
│   └── SeedContent/
│       ├── LLDProblemsContent.swift
│       ├── CSConceptsContent.swift
│       ├── LLDProblems/        # 10 LLD problems
│       └── CSConcepts/         # 7 CS categories
├── Secrets.swift              # ⚠️ NOT COMMITTED (gitignored)
└── Secrets.example.swift      # Template for API keys
```

## 🔐 Secrets Management

The app uses `Secrets.swift` for API keys (protected by `.gitignore`):

- **Local Development:** Create `Secrets.swift` from the template
- **CI/CD:** Use GitHub Actions secrets with environment variables

### Environment Variable Override
```bash
export GEMINI_API_KEY="your_api_key"
```

## 📤 Adding to GitHub

### Initial Setup

```bash
# Navigate to project
cd /path/to/DevAscent/DevAscent

# Initialize git (if not already)
git init

# Ensure Secrets.swift won't be committed
# .gitignore already protects it

# Add files
git add .

# Commit
git commit -m "Initial commit: DevAscent GS Interview Prep"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/DevAscent.git
git branch -M main
git push -u origin main
```

### Protecting Secrets in CI/CD

1. Go to repo: **Settings** → **Secrets and variables** → **Actions**
2. Add secret: `GEMINI_API_KEY` = your API key
3. In workflow file, access via `${{ secrets.GEMINI_API_KEY }}`

## 📱 Features

- **10 LLD Problems** - Goldman Sachs style design questions
- **70+ CS Concepts** - OS, Java, DBMS, Networking, Spring Boot, SQL, OOPs
- **AI Interviewer** - Gemini 2.5 Flash integration
- **Mermaid Diagrams** - Visual class diagrams

## 🧪 Content Updates

When adding new content:
1. Add new file to `SeedContent/LLDProblems/` or `SeedContent/CSConcepts/`
2. Update the aggregator file
3. Increment `contentVersion` in `DataSeeder.swift`

## 📄 License

MIT License
