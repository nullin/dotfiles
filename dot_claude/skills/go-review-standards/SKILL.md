---
description: Review Go code changes in PRs for idiomatic Go patterns and best practices based on cw-eng-cli code review standards
---

# Go Code Review Best Practices

Use this guide when reviewing pull requests that modify Go code. These best practices are derived from code reviews by zachspar and lsiv568 in the cw-eng-cli repository.

## 1. Constants and Standard Library Usage

### ✅ Use Standard Library Constants

**Bad:**
```go
req, err := http.NewRequest("GET", url, nil)
req.Method = "POST"
```

**Good:**
```go
req, err := http.NewRequest(http.MethodGet, url, nil)
req.Method = http.MethodPost
```

**Rationale:** Use standard library constants instead of magic strings. This prevents typos, makes code more maintainable, and communicates intent clearly.

**References:** PR #237 (lsiv568)

### ✅ Extract Magic Values to Constants

**Bad:**
```go
if retries > 5 {
    return errors.New("too many retries")
}
time.Sleep(30 * time.Second)
```

**Good:**
```go
const (
    maxRetries = 5
    retryDelay = 30 * time.Second
)

if retries > maxRetries {
    return errors.New("too many retries")
}
time.Sleep(retryDelay)
```

**Rationale:** Named constants make code self-documenting and easier to modify **when used multiple times**.

**References:** PR #203 (lsiv568)

### ❌ Avoid Single-Use Constants

**Bad:**
```go
const (
    apiURL = "https://api.example.com/v1/users"
)

func fetchUsers() ([]User, error) {
    resp, err := http.Get(apiURL)  // Only used here
    // ...
}
```

**Good:**
```go
func fetchUsers() ([]User, error) {
    resp, err := http.Get("https://api.example.com/v1/users")
    // ...
}
```

**Rationale:** Constants should only be extracted when:
1. **Used multiple times** (DRY principle)
2. **Provide semantic clarity** beyond what the value itself shows
3. **Represent configuration** that might need to change globally

**Exception - System Configuration Values:**
```go
// Good: System paths and configuration defaults are reasonable constants
const (
    defaultInstallDir = "/usr/local/bin"
    defaultTimeout    = 30 * time.Second
)
```

These represent system conventions and configuration, not arbitrary data values.

**References:** PR #250, Grug Brain philosophy

### ✅ Place Package Constants at Top of File

**Bad:**
```go
package myapp

import (...)

type Service struct {...}

const maxRetries = 5  // Hidden in middle of file

func (s *Service) process() {...}
```

**Good:**
```go
package myapp

import (...)

const (
    maxRetries     = 5
    defaultTimeout = 30 * time.Second
)

type Service struct {...}

func (s *Service) process() {...}
```

**Rationale:** Package-level constants belong at the top of the file after imports for discoverability and consistency with Go conventions.

**References:** PR #250, Go Code Review Comments

## 2. Error Handling

### ✅ Never Ignore Errors Without Reason

**Bad:**
```go
data, _ := io.ReadAll(resp.Body)
_ = resp.Body.Close()
```

**Good:**
```go
data, err := io.ReadAll(resp.Body)
if err != nil {
    return fmt.Errorf("failed to read response: %w", err)
}
if err := resp.Body.Close(); err != nil {
    log.Warn("failed to close response body", "error", err)
}
```

**Rationale:** Ignoring errors can hide bugs and lead to unexpected behavior. If you must ignore an error, add a comment explaining why.

**References:** PR #203 (lsiv568, multiple comments)

### ✅ Proper Resource Cleanup

**Bad:**
```go
resp, err := http.Get(url)
if err != nil {
    return err
}
body, err := io.ReadAll(resp.Body)
resp.Body.Close()  // Won't execute if ReadAll fails
```

**Good:**
```go
resp, err := http.Get(url)
if err != nil {
    return err
}
defer resp.Body.Close()

body, err := io.ReadAll(resp.Body)
if err != nil {
    return fmt.Errorf("failed to read body: %w", err)
}
```

**Rationale:** Use `defer` to ensure resources are cleaned up even when errors occur. This prevents resource leaks.

**References:** PR #203, PR #228 (lsiv568, zachspar)

### ✅ Handle Errors in defer Blocks

**Bad:**
```go
defer func() {
    if err := os.Remove(tempFile); err != nil {
        fmt.Println("Failed to remove file")  // Ignoring error
    }
}()
```

**Good:**
```go
defer func() {
    if err := os.Remove(tempFile); err != nil && !os.IsNotExist(err) {
        // Only warn if error is NOT "file doesn't exist"
        log.Warn("failed to remove temporary file", "file", tempFile, "error", err)
    }
}()
```

**Rationale:**
- Check for expected errors like `os.IsNotExist` to avoid false warnings
- Use proper logging instead of `fmt.Println` for tracking failures
- Document why errors are being ignored or handled differently

**References:** PR #250

## 3. Return Values: Pointer vs Value

### ✅ Return Small Structs by Value

**Bad:**
```go
type TokenData struct {
    AccessToken  string
    RefreshToken string
}

func getToken() (*TokenData, error) {
    return &TokenData{
        AccessToken:  "...",
        RefreshToken: "...",
    }, nil
}
```

**Good:**
```go
type TokenData struct {
    AccessToken  string
    RefreshToken string
}

func getToken() (TokenData, error) {
    return TokenData{
        AccessToken:  "...",
        RefreshToken: "...",
    }, nil
}
```

**Rationale:** Small, immutable data structs should be returned by value. This is the idiomatic Go approach and can be more efficient. Reserve pointers for large structs or structs that will be mutated.

**General Go Idiom:**
- Small, immutable data structs → return by value
- Large structs or structs that will be mutated → return by pointer

**References:** PR #203 (zachspar, multiple comments about pointer returns)

## 4. Boolean and Zero Values

### ✅ Use Zero Values

**Bad:**
```go
var isEnabled bool
isEnabled = false  // Unnecessary
```

**Good:**
```go
var isEnabled bool  // Already false by default
```

**Rationale:** The default zero value for `bool` is `false`. Don't explicitly set it.

**References:** PR #158 (lsiv568)

### ✅ Simplify Redundant Conditionals

**Bad:**
```go
name, ok := os.LookupEnv("USER")
if !ok {
    // do something
}
if name == "" {  // This is redundant if !ok
    // do the same thing
}
```

**Good:**
```go
name, ok := os.LookupEnv("USER")
if !ok || name == "" {
    // handle both cases together
}
```

**Rationale:** Combine related checks to reduce redundancy and improve clarity.

**References:** PR #188 (lsiv568)

## 5. Encapsulation and API Design

### ✅ Encapsulate Internal Details

**Bad:**
```go
// Exported constants in package
const CoderUserEnvVar = "CODER_USER"
const CoderOrgEnvVar = "CODER_ORG"

// Used throughout codebase
user := os.Getenv(coder.CoderUserEnvVar)
```

**Good:**
```go
// Unexported constants
const coderUserEnvVar = "CODER_USER"
const coderOrgEnvVar = "CODER_ORG"

// Exported function
func GetUser() string {
    return os.Getenv(coderUserEnvVar)
}

// Used throughout codebase
user := coder.GetUser()
```

**Rationale:** Encapsulate implementation details. This prevents knowledge of internal env var names from spreading outside package boundaries, making future changes easier.

**References:** PR #188 (lsiv568, emphasis on encapsulation)

### ✅ Avoid Unnecessary State Tracking

**Bad:**
```go
type Service struct {
    client          *Client
    isAuthenticated bool  // Unnecessary state
}

func (s *Service) ensureAuth() error {
    if s.isAuthenticated {
        return nil
    }
    // auth logic
    s.isAuthenticated = true
    return nil
}
```

**Good:**
```go
type Service struct {
    client *Client
}

func (s *Service) ensureAuth() error {
    // Check if client has token
    if s.client != nil && s.client.HasToken() {
        return nil
    }
    // auth logic
    return nil
}
```

**Rationale:** Avoid tracking state that can be derived or checked directly. State tracking increases cognitive overhead and is another thing to maintain (e.g., must remember to set to false on logout).

**References:** PR #158 (lsiv568, detailed explanation about state management)

### ❌ Avoid Unnecessary Function Fields

**Bad:**
```go
type Config struct {
    downloadURLFunc func() string  // Function stored in struct
}

func NewConfig(urlFunc func() string) *Config {
    return &Config{
        downloadURLFunc: urlFunc,  // Store function
    }
}

func (c *Config) Process() error {
    url := c.downloadURLFunc()  // Call it later
    // ...
}

// Usage
cfg := NewConfig(func() string {
    return "https://example.com/" + runtime.GOOS
})
```

**Good:**
```go
type Config struct {
    downloadURL string  // Simple string field
}

func NewConfig(url string) *Config {
    return &Config{
        downloadURL: url,  // Store the value
    }
}

func (c *Config) Process() error {
    url := c.downloadURL  // Read the value
    // ...
}

// Usage - compute once at construction
url := "https://example.com/" + runtime.GOOS
cfg := NewConfig(url)
```

**Rationale:** Function fields add complexity without benefit when:
- Values don't change during program execution (e.g., `runtime.GOOS`)
- The function is only called once
- No lazy evaluation benefit exists
- Testing doesn't require function injection

**When function fields ARE appropriate:**
- Value truly changes between calls (e.g., `time.Now()`)
- Expensive computation should be lazy-loaded
- Dependency injection for testing (but consider interfaces instead)

**References:** PR #250, Grug Brain philosophy

## 6. Code Organization and DRY

### ✅ Extract Duplicate Logic

**Bad:**
```go
func validateUserToken(token string) error {
    if token == "" {
        return errors.New("token is empty")
    }
    if !strings.HasPrefix(token, "ghp_") {
        return errors.New("invalid token format")
    }
    // ... more validation
    return nil
}

func validateAppToken(token string) error {
    if token == "" {
        return errors.New("token is empty")
    }
    if !strings.HasPrefix(token, "ghp_") {
        return errors.New("invalid token format")
    }
    // ... same validation repeated
    return nil
}
```

**Good:**
```go
func validateToken(token string) error {
    if token == "" {
        return errors.New("token is empty")
    }
    if !strings.HasPrefix(token, "ghp_") {
        return errors.New("invalid token format")
    }
    return nil
}

func validateUserToken(token string) error {
    return validateToken(token)
}

func validateAppToken(token string) error {
    return validateToken(token)
}
```

**Rationale:** Extract common validation or logic into separate functions to reduce duplication and improve maintainability.

**References:** PR #203 (lsiv568)

### ✅ Use Appropriate Packages

**Bad:**
```go
fmt.Println("Please enter your username:")
```

**Good:**
```go
tui.Prompt("Please enter your username:")  // Using the TUI package
```

**Rationale:** Use the appropriate internal packages that provide better abstractions and consistency. In this codebase, use the `tui` package for user interactions instead of raw `fmt`.

**References:** PR #203 (lsiv568)

## 7. Cobra CLI Patterns

### ✅ Use MarkFlagsMutuallyExclusive

**Bad:**
```go
cmd.Flags().Bool("start", false, "Start service")
cmd.Flags().Bool("stop", false, "Stop service")
// Both flags can be set simultaneously
```

**Good:**
```go
cmd.Flags().Bool("start", false, "Start service")
cmd.Flags().Bool("stop", false, "Stop service")
cmd.MarkFlagsMutuallyExclusive("start", "stop")
```

**Rationale:** Prevent users from providing conflicting flags by explicitly marking them as mutually exclusive.

**References:** PR #180 (zachspar)

### ✅ Provide Clear Error Messages

**Bad:**
```go
if err := checkPrereqs(); err != nil {
    return err  // Generic error
}
```

**Good:**
```go
if err := checkPrereqs(); err != nil {
    return fmt.Errorf("missing prerequisites: run 'cw dev init' first. Original error: %w", err)
}
```

**Rationale:** Provide actionable error messages that guide users toward solutions.

**References:** PR #180 (zachspar, lsiv568)

## 8. Type Design

### ✅ Create Structs to Group Related Data

**Bad:**
```go
func StartDeviceFlow() (string, string, error) {
    // returns accessToken, refreshToken, error
    // Unclear which string is which
}

accessToken, refreshToken, err := StartDeviceFlow()
```

**Good:**
```go
type TokenResponse struct {
    AccessToken  string
    RefreshToken string
}

func StartDeviceFlow() (TokenResponse, error) {
    return TokenResponse{
        AccessToken:  "...",
        RefreshToken: "...",
    }, nil
}

resp, err := StartDeviceFlow()
// resp.AccessToken and resp.RefreshToken are clear
```

**Rationale:** Use structs to group related return values. This makes the API clearer and easier to extend in the future (e.g., adding TokenExpiry).

**References:** PR #203 (lsiv568, detailed suggestion)

## 9. Testing and Maintainability

### ✅ Design for Testability

**Bad:**
```go
func processData() error {
    cmd := exec.Command("external-tool", "arg")
    output, err := cmd.CombinedOutput()
    // Hard to test
}
```

**Good:**
```go
type CommandRunner interface {
    Run(name string, args ...string) ([]byte, error)
}

type Service struct {
    cmdRunner CommandRunner
}

func (s *Service) processData() error {
    output, err := s.cmdRunner.Run("external-tool", "arg")
    // Easy to mock cmdRunner in tests
}
```

**Rationale:** Use interfaces and dependency injection to make code testable. This allows mocking external dependencies.

**References:** PR #154 (lsiv568, discussion about abstraction for testing)

### ✅ Avoid Premature Optimization

**Guidance:** Don't build features for hypothetical future requirements. Implement what's needed now, with clean abstractions that make future changes easier.

**References:** PR #186 (lsiv568, discussion about post-install command ordering)

## 10. Code Maintenance

### ✅ Document Non-Obvious Decisions

**Bad:**
```go
_ = someOperation()  // Ignoring error
```

**Good:**
```go
// Ignoring error because operation is best-effort and failure is acceptable
// See issue #123 for context
_ = someOperation()
```

**Rationale:** If you're doing something unusual (like ignoring an error), explain why so future maintainers understand.

**References:** PR #203 (lsiv568)

### ✅ Use Project Tools

**Guidance:** Use `make imports` to organize and format imports automatically.

**References:** PR #203 (lsiv568)

## Review Checklist

When reviewing Go PRs, check for:

- [ ] Are standard library constants used instead of magic strings?
- [ ] Are single-use constants avoided (unless system configuration)?
- [ ] Are package-level constants placed at the top of the file?
- [ ] Are errors handled properly (not ignored)?
- [ ] Are errors in `defer` blocks handled correctly (checking for expected errors)?
- [ ] Are resources properly cleaned up with `defer`?
- [ ] Are small structs returned by value, not pointer?
- [ ] Are boolean zero values used (not explicitly set to false)?
- [ ] Is duplicate logic extracted into functions?
- [ ] Are implementation details properly encapsulated?
- [ ] Is unnecessary state tracking avoided?
- [ ] Are function fields avoided when simple value fields would work?
- [ ] Are mutually exclusive flags marked appropriately?
- [ ] Are error messages clear and actionable?
- [ ] Are related data grouped into structs?
- [ ] Is the code designed for testability?
- [ ] Are non-obvious decisions documented?
- [ ] Does the code follow the single responsibility principle?

## References

This guide is based on code reviews from the following PRs (ordered by relevance):
- PR #250: Refactor devkit app installation (dsridhar-cw)
- PR #203: OAuth GitHub App token refresh (zachspar, lsiv568)
- PR #237: Add buf, doppler to devkit (lsiv568)
- PR #188: Coder.com username lookup (lsiv568)
- PR #158: GitHub token support (lsiv568)
- PR #180: CKS command (zachspar, lsiv568)
- PR #186: Post-install command support (lsiv568, zachspar)
- PR #154: DevKit command refactor (lsiv568)
- PR #160: Create repo + archetype behavior (zachspar)
- PR #144: Command structure refactor (zachspar)
- PR #132: Archetype engine (zachspar)
- PR #131: Input validation interface (zachspar)
- PR #129: Command refactor (lsiv568)
- PR #228: Resource leak fix (asbarron, reviewed by team)

## Additional Resources

- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
- [Grug Brain Developer](https://grugbrain.dev/)

---

**Maintainers:** This document should be updated as new patterns emerge from code reviews.
**Last Updated:** 2026-02-07
**Derived From:** Code reviews by zachspar, lsiv568, and dsridhar-cw in cw-eng-cli repository
