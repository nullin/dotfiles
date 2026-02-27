# Error Handling Standards

## Core Principles

1. **Fail fast** - Detect errors early, close to the source
2. **Be explicit** - Don't hide errors or convert to silent failures
3. **Provide context** - Wrap with `fmt.Errorf("failed to X: %w", err)`
4. **Clean up resources** - Use defer, try-finally, or context managers
5. **Don't log and return** - Either handle it, log it, or propagate it (not multiple)

## Language-Specific Patterns

**Go:**

```go
// Always check errors
if err != nil {
    return fmt.Errorf("failed to process user %d: %w", userID, err)
}

// Use sentinel errors
var ErrNotFound = errors.New("not found")
```

**Python:**

```python
# Specific exceptions, not bare except:
try:
    result = do_something()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    raise

# Context managers for cleanup
with open('file.txt') as file:
    data = file.read()
```

**JavaScript/TypeScript:**

```typescript
// Proper async error handling
try {
    const response = await fetch(url);
    if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
    }
    return await response.json();
} catch (error) {
    logger.error('Failed to fetch:', error);
    throw new Error('Data fetch failed', { cause: error });
}
```

## Project Standards

- **Validate at system boundaries only** (not every layer)
- **Never log secrets** (passwords, tokens, credit cards)
- **User errors (4xx):** Return clear, actionable message (no stack trace)
- **System errors (5xx):** Log with context, return generic user message
- **Use retries for transient errors** (network issues, rate limits)

## Error Categories

### User Errors (4xx)

- Caused by invalid user input
- User can fix by changing input
- Should not be logged as errors (maybe info level)
- Example: "Email address is required. Please provide a valid email."

### System Errors (5xx)

- Caused by system failure
- User cannot fix
- Should be logged and alerted
- Example: "An internal error occurred. Please try again later."

### Transient Errors

- Temporary failures that might succeed on retry
- Network issues, rate limits, temporary unavailability
- Use exponential backoff for retries

## Resource Cleanup

**Always clean up resources:**

```go
// Go: defer
file, err := os.Open(path)
if err != nil {
    return err
}
defer file.Close()  // Guaranteed cleanup
```

```python
# Python: with statement
with open(path) as file:
    data = file.read()
# File automatically closed
```

## When to Handle vs Propagate

**Handle when:**

- You can fix the error
- You can provide a fallback
- You're at an API boundary
- You need to convert error types

**Propagate when:**

- You can't fix it
- Caller is better positioned to handle it
- You want to add context

## Grug Brain Perspective

From [grug-brain.md](grug-brain.md):

- Don't add "just in case" error handling - only handle errors that can actually occur
- Trust internal code - don't validate at every layer
- Validate at boundaries - user input, external APIs, file I/O
- Keep it simple - complex error hierarchies cause confusion

```python
# Bad: Over-engineered
class BaseError(Exception): pass
class ServiceError(BaseError): pass
class DatabaseServiceError(ServiceError): pass

# Good: Simple, clear
class ValidationError(Exception): pass
class DatabaseError(Exception): pass
```

## Transient Tool/API Failures

When a tool call or API request returns a 500 error (e.g., `API Error: 500 {"type":"error","error":{"type":"api_error","message":"Internal server error"}}`), **automatically retry at least once** before reporting the failure. These are transient server-side errors that frequently resolve on a second attempt.

- Do not ask the user whether to retry - just retry immediately
- If the retry also fails, then report the error

## Related

- [grug-brain.md](grug-brain.md) - Simplicity in error handling
- [security.md](security.md) - Don't leak info in error messages
- [testing.md](testing.md) - Test error paths
