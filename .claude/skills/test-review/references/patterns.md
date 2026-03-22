# Test Quality Patterns Reference

## Table of Contents

1. [Dead Tests](#dead-tests)
2. [Coverage Theater](#coverage-theater)
3. [Over-Mocked Tests](#over-mocked-tests)
4. [Implementation-Coupled Tests](#implementation-coupled-tests)
5. [Good Test Characteristics](#good-test-characteristics)
6. [Bug Patterns Found Via Testing Gaps](#bug-patterns)

---

## Dead Tests

Tests that exist but don't actually test the code they appear to test.

### Logic-Flow Simulation

The test simulates what the function does using local variables instead of calling the function:

```go
// BAD: Tests logic flow, not the actual function
func TestCheckHealth_LogicFlow(t *testing.T) {
    agentConnected := true
    clusterReady := true
    healthy := agentConnected && clusterReady  // simulates the function
    assert.True(t, healthy)
}

// GOOD: Tests the actual function
func TestCheckHealth(t *testing.T) {
    svc := NewHealthChecker(mockAgent, mockCluster)
    healthy, err := svc.CheckHealth(ctx)
    assert.NoError(t, err)
    assert.True(t, healthy)
}
```

### Missing Assertions

The test calls the function but never checks the result:

```python
# BAD: Runs the code but validates nothing
def test_process_data():
    processor = DataProcessor()
    processor.process(sample_data)  # no assertion

# GOOD: Validates the output
def test_process_data():
    processor = DataProcessor()
    result = processor.process(sample_data)
    assert result.status == "complete"
    assert len(result.items) == 3
```

---

## Coverage Theater

Tests that inflate coverage numbers without validating behavior.

### Call-and-Forget

```go
// BAD: Gets coverage credit but tests nothing
func TestNewService(t *testing.T) {
    svc := NewService(config)
    _ = svc  // unused
}

// GOOD: Validates the service was configured correctly
func TestNewService(t *testing.T) {
    svc := NewService(config)
    assert.Equal(t, 15*time.Second, svc.client.Timeout)
    assert.NotNil(t, svc.logger)
}
```

### Testing Constants

```typescript
// BAD: Tests that a constant equals itself
test('content type is JSON', () => {
    expect(CONTENT_TYPE_JSON).toBe('application/json');
});
```

---

## Over-Mocked Tests

When mock setup dominates the test, the test is testing the mock configuration, not the code.

```go
// BAD: 20 lines of mock setup, 2 lines of actual test
func TestProcessOrder(t *testing.T) {
    mockDB := new(MockDB)
    mockDB.On("GetUser", mock.Anything).Return(&User{ID: 1}, nil)
    mockDB.On("GetInventory", mock.Anything).Return(&Inventory{Count: 5}, nil)
    mockDB.On("CreateOrder", mock.Anything).Return(&Order{ID: 99}, nil)
    mockDB.On("UpdateInventory", mock.Anything).Return(nil)
    mockDB.On("SendNotification", mock.Anything).Return(nil)
    mockDB.On("LogAudit", mock.Anything).Return(nil)
    // ... more mock setup ...

    svc := NewOrderService(mockDB)
    err := svc.ProcessOrder(ctx, orderReq)
    assert.NoError(t, err)
}

// BETTER: Use integration test or simplify the interface
func TestProcessOrder(t *testing.T) {
    db := setupTestDB(t)
    svc := NewOrderService(db)
    err := svc.ProcessOrder(ctx, orderReq)
    assert.NoError(t, err)
    // Validate actual DB state
    order, _ := db.GetOrder(ctx, 99)
    assert.Equal(t, "completed", order.Status)
}
```

---

## Implementation-Coupled Tests

Tests that break when you refactor even though behavior is unchanged.

```python
# BAD: Tests internal data structure
def test_cache_uses_dict():
    cache = Cache()
    cache.set("key", "value")
    assert isinstance(cache._storage, dict)  # implementation detail
    assert "key" in cache._storage            # implementation detail

# GOOD: Tests cache behavior
def test_cache_stores_and_retrieves():
    cache = Cache()
    cache.set("key", "value")
    assert cache.get("key") == "value"

def test_cache_returns_none_for_missing():
    cache = Cache()
    assert cache.get("missing") is None
```

---

## Good Test Characteristics

### Tests a Real User Scenario

```go
func TestParseStages_DefaultsWhenEmpty(t *testing.T) {
    // User runs `cw dev init` with no --stages flag
    // Should default to running all stages
    stages := parseStages(nil)
    assert.Equal(t, SupportedStages, stages)
}
```

### Tests Error Users Will Hit

```go
func TestValidateInput_RequiredFieldEmpty(t *testing.T) {
    // User submits form with required field blank
    input := Input{DisplayName: "Project Name", Required: true}
    err := validator.Validate(ctx, input, "")
    assert.ErrorIs(t, err, ErrInputValidationFailed)
}
```

### Table-Driven With Clear Names

```go
func TestNormalizeVersion(t *testing.T) {
    tests := []struct {
        name     string
        input    string
        expected string
    }{
        {"strips v prefix",          "v1.2.3",        "1.2.3"},
        {"no-op without prefix",     "1.2.3",         "1.2.3"},
        {"preserves prerelease",     "v1.2.3-beta.1", "1.2.3-beta.1"},
        {"handles empty string",     "",               ""},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            assert.Equal(t, tt.expected, NormalizeVersion(tt.input))
        })
    }
}
```

---

## Bug Patterns

Common bugs discovered through testing gap analysis:

### Slice Append on Pre-Sized Slice

```go
// BUG: make([]string, len) creates len zero-value entries, append adds AFTER them
values := make([]string, len(items))
for _, item := range items {
    values = append(values, item.Name)  // produces ["", "", "", "actual", "values"]
}

// FIX: Use capacity, not length
values := make([]string, 0, len(items))
```

### Created But Unused Variable

```go
// BUG: Transport is configured but never assigned to client
func NewHTTPClient() *http.Client {
    transport := http.DefaultTransport.(*http.Transport).Clone()
    transport.MaxIdleConns = 100
    return &http.Client{Timeout: 15 * time.Second}  // transport not used
}

// FIX: Assign the transport
return &http.Client{Timeout: 15 * time.Second, Transport: transport}
```

### Missing Error Check After Close

```go
// BUG: Error from Close is silently discarded
defer file.Close()

// BETTER: Check error in defer
defer func() {
    if err := file.Close(); err != nil {
        logger.Error("close file", err)
    }
}()
```
