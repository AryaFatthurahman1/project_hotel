# Contribution Guidelines

Welcome to the **Quantum Hybrid Systems** project! We're excited to have you contribute to this cutting-edge platform integrating quantum computing, AI agents, and classical HPC.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Format](#commit-message-format)

---

## 🤝 Code of Conduct

Be respectful, inclusive, and professional. We're building a platform for the future of computing - let's do it together!

---

## 🚀 Getting Started

### 1. Fork the Repository
```bash
# Go to https://github.com/AryaFatthurahman1/project_hotel
# Click "Fork" in the top right corner
```

### 2. Clone Your Fork
```bash
git clone https://github.com/YOUR_USERNAME/project_hotel.git
cd project_hotel
```

### 3. Add Upstream Remote
```bash
git remote add upstream https://github.com/AryaFatthurahman1/project_hotel.git
```

### 4. Fetch Latest Changes
```bash
git fetch upstream
git checkout quantum-hybrid-systems
git rebase upstream/quantum-hybrid-systems
```

---

## 💻 Development Setup

### Prerequisites
- **Python 3.10+** - Quantum core and AI agents
- **Node.js 18+** - Frontend development
- **Go 1.21+** - High-performance services
- **Rust 1.70+** - Performance accelerators
- **Kotlin 1.9+** - Spring Boot microservices
- **Docker & Docker Compose 20.10+** - Containerization
- **Git** - Version control

### Initial Setup

```bash
# Clone and navigate
git clone https://github.com/AryaFatthurahman1/project_hotel.git
cd project_hotel
git checkout quantum-hybrid-systems

# Run setup script (installs all dependencies)
./scripts/setup.sh

# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# Verify services are running
./scripts/health-check.sh
```

### IDE Setup

**VS Code** (Recommended)
```bash
# Install extensions
code --install-extension ms-python.python
code --install-extension golang.Go
code --install-extension rust-lang.rust-analyzer
code --install-extension esbenp.prettier-vscode
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
```

**IntelliJ IDEA** (Kotlin/Java)
- Install Kotlin plugin
- Install Python plugin
- Install Go plugin

**PyCharm** (Python)
- Install Rust plugin
- Install Go plugin

---

## 📝 Making Changes

### 1. Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

**Branch naming conventions:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation improvements
- `refactor/` - Code refactoring
- `test/` - Test additions
- `perf/` - Performance improvements

### 2. Make Your Changes

**File Organization:**
- Backend changes → `/backend`, `/quantum-core`, `/ai-agents`
- Frontend changes → `/frontend`
- Infrastructure → `/infrastructure`
- Documentation → `/docs`
- Tests → `/tests`

### 3. Keep Commits Clean
```bash
# Make logical, atomic commits
git add .
git commit -m "feat: add quantum circuit optimizer"

# Or interactive staging
git add -p
git commit
```

---

## ✅ Testing

### Run All Tests
```bash
./scripts/run-tests.sh
```

### Test by Language

**Python Tests**
```bash
cd backend/python-api
pytest tests/ -v
pytest tests/ --cov=app/
```

**TypeScript/JavaScript Tests**
```bash
cd frontend/next-app
npm test
npm run test:e2e
```

**Go Tests**
```bash
cd backend/go-services
go test ./...
go test -cover ./...
```

**Rust Tests**
```bash
cd backend/rust-accelerators
cargo test
cargo test --all
```

### Code Quality

**Linting**
```bash
# Python
flake8 backend/
pylint backend/

# JavaScript/TypeScript
npm run lint

# Go
golangci-lint run

# Rust
cargo clippy
```

**Formatting**
```bash
# Python
black backend/
isort backend/

# JavaScript/TypeScript
prettier --write .

# Go
gofmt -w .

# Rust
cargo fmt
```

### Local Build & Test
```bash
# Build all Docker images
./scripts/build-docker.sh

# Run integration tests
docker-compose -f docker-compose.dev.yml run test

# Run security scan
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image --severity HIGH,CRITICAL
```

---

## 🔄 Submitting Changes

### 1. Update Your Branch
```bash
# Fetch latest changes from upstream
git fetch upstream

# Rebase on latest main branch
git rebase upstream/quantum-hybrid-systems

# Force push to your fork (only if you have local commits)
git push --force-with-lease origin feature/your-feature-name
```

### 2. Push Your Changes
```bash
git push origin feature/your-feature-name
```

### 3. Create Pull Request

**Go to GitHub** and click "New Pull Request"

**PR Title Format:**
```
[TYPE] Short description - Issue #123

Examples:
- [FEAT] Add quantum circuit visualizer - Issue #456
- [FIX] Fix memory leak in quantum simulator - Issue #789
- [DOCS] Update API documentation
```

**PR Description Template:**
```markdown
## Description
Brief description of what this PR does.

## Changes
- Change 1
- Change 2
- Change 3

## Related Issue
Fixes #123

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

## How Has This Been Tested?
Describe the tests you ran and how to reproduce them.

## Testing Checklist
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Linting passes
- [ ] Code coverage maintained/improved
- [ ] Documentation updated

## Screenshots/Demos
Include if applicable for UI changes.

## Performance Impact
- [ ] No performance impact
- [ ] Performance improved by X%
- [ ] Requires optimization

## Deployment Notes
Any special deployment considerations?
```

### 4. Review Process

- Maintainers will review your PR within 48 hours
- Address any feedback or requested changes
- Ensure all CI checks pass
- Once approved, your PR will be merged!

---

## 📐 Code Style Guidelines

### Python

```python
# Follow PEP 8
# Use type hints
def quantum_circuit_optimizer(
    circuit: QuantumCircuit,
    max_gates: int = 100
) -> QuantumCircuit:
    """Optimize quantum circuit for minimal gate depth.
    
    Args:
        circuit: Input quantum circuit
        max_gates: Maximum allowed gates
        
    Returns:
        Optimized quantum circuit
        
    Raises:
        ValueError: If optimization fails
    """
    pass

# Documentation strings
class QuantumOrchestrator:
    """Orchestrates quantum and classical computation.
    
    This class manages hybrid quantum-classical workflows,
    providing seamless execution across multiple quantum backends.
    """
    pass

# Use doctest
def fibonacci(n: int) -> int:
    """Return nth Fibonacci number.
    
    >>> fibonacci(5)
    5
    >>> fibonacci(10)
    55
    """
    pass
```

**Tools:**
- `black` for formatting
- `isort` for imports
- `flake8` for linting
- `mypy` for type checking
- `pytest` for testing

### TypeScript/JavaScript

```typescript
// Use strict mode
"use strict";

// Use interface definitions
interface QuantumJob {
  id: string;
  circuit: QuantumCircuit;
  provider: string;
  status: JobStatus;
}

// Use async/await
async function executeQuantumJob(job: QuantumJob): Promise<Result> {
  try {
    const result = await quantum_backend.execute(job);
    return result;
  } catch (error) {
    logger.error("Quantum job failed", { jobId: job.id, error });
    throw error;
  }
}

// Use descriptive names
const submittedQuantumJobs: Map<string, QuantumJob> = new Map();

// Add comments for complex logic
// Retry quantum execution with exponential backoff
for (let attempt = 0; attempt < maxRetries; attempt++) {
  try {
    return await executeJob(job);
  } catch (error) {
    await sleep(Math.pow(2, attempt) * 1000);
  }
}
```

**Tools:**
- `prettier` for formatting
- `eslint` for linting
- `jest` for testing
- `typescript` for type checking

### Go

```go
// Use package-level documentation
// Package quantum provides quantum circuit execution capabilities.
package quantum

import (
    "context"
    "fmt"
)

// QuantumExecutor executes quantum circuits on backends.
type QuantumExecutor struct {
    backend Backend
    cache   *Cache
}

// Execute runs a quantum circuit and returns results.
func (qe *QuantumExecutor) Execute(ctx context.Context, circuit Circuit) (Result, error) {
    if ctx.Err() != nil {
        return nil, ctx.Err()
    }
    
    // Check cache first
    if cached, ok := qe.cache.Get(circuit.Hash()); ok {
        return cached, nil
    }
    
    // Execute and cache result
    result, err := qe.backend.Execute(ctx, circuit)
    if err != nil {
        return nil, fmt.Errorf("execution failed: %w", err)
    }
    
    qe.cache.Set(circuit.Hash(), result)
    return result, nil
}
```

**Tools:**
- `gofmt` for formatting
- `golangci-lint` for linting
- `testing` package for testing
- `go test -cover` for coverage

### Rust

```rust
/// Executes a quantum circuit on the hybrid engine.
///
/// # Arguments
/// * `circuit` - The quantum circuit to execute
/// * `backend` - The quantum backend to use
///
/// # Returns
/// Result containing quantum state or error
pub fn execute_circuit(
    circuit: &QuantumCircuit,
    backend: &str,
) -> Result<QuantumState, ExecutionError> {
    validate_circuit(circuit)?;
    
    match backend {
        "simulator" => simulate(circuit),
        "real_device" => submit_to_device(circuit),
        _ => Err(ExecutionError::UnknownBackend),
    }
}

// Use meaningful error types
#[derive(Debug)]
pub enum ExecutionError {
    InvalidCircuit(String),
    BackendError(String),
    TimeoutError,
}
```

**Tools:**
- `rustfmt` for formatting
- `clippy` for linting
- `cargo test` for testing

---

## 📝 Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style (no logic change)
- `refactor:` - Code refactoring
- `perf:` - Performance improvement
- `test:` - Test addition/modification
- `chore:` - Build, CI, dependencies

**Scope:**
- `quantum:` - Quantum core
- `ai:` - AI agents
- `api:` - API changes
- `frontend:` - Frontend changes
- `infra:` - Infrastructure
- `security:` - Security changes

**Subject:**
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end
- Max 50 characters

**Body:**
- Explain what and why, not how
- Wrap at 72 characters
- Reference issues: "Fixes #123"

**Examples:**

```
feat(quantum): add variational quantum eigensolver

Implement VQE algorithm with support for multiple ansatz types.
Includes parametrized circuit generation and classical optimization.

Fixes #456
```

```
fix(api): handle quantum job timeout gracefully

Improve error handling when quantum jobs exceed time limits.
Now returns meaningful error message instead of generic timeout.

Fixes #789
```

---

## 🔍 Review Checklist

Before submitting your PR, verify:

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] No hardcoded secrets/credentials
- [ ] Git history is clean
- [ ] Commit messages follow format
- [ ] All tests pass locally
- [ ] No linting warnings
- [ ] Performance acceptable
- [ ] Security considerations addressed

---

## 📚 Resources

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Python Best Practices](https://pep8.org/)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)

---

## ❓ Questions?

- Open an issue with `[QUESTION]` label
- Start a discussion in GitHub Discussions
- Contact maintainers

---

**Thank you for contributing to the future of quantum computing! 🚀**
