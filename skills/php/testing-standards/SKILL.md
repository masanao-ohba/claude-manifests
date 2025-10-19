---
name: testing-standards
description: PHPUnit testing conventions and best practices for any PHP project
---

# PHP Testing Standards

Language-level testing standards using PHPUnit, applicable to any PHP project.

## PHPUnit Basics

### Test Class Structure

```php
<?php
declare(strict_types=1);

namespace App\Test\TestCase\Service;

use PHPUnit\Framework\TestCase;
use App\Service\UserService;

/**
 * UserService Test
 *
 * Tests user service functionality
 *
 * @covers \App\Service\UserService
 */
class UserServiceTest extends TestCase
{
    private UserService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new UserService();
    }

    protected function tearDown(): void
    {
        unset($this->service);
        parent::tearDown();
    }

    public function testSomething(): void
    {
        // Test implementation
    }
}
```

### Test Method Naming

```php
// Pattern: test + MethodName + Scenario
public function testValidateUserReturnsTrue

WhenDataIsValid(): void {}
public function testValidateUserReturnsFalseWhenEmailInvalid(): void {}
public function testValidateUserThrowsExceptionWhenAgeNegative(): void {}

// Alternative: use @test annotation
/**
 * @test
 */
public function it_validates_user_with_valid_data(): void {}
```

## Assertions

### Common Assertions

```php
// Equality
$this->assertEquals($expected, $actual);
$this->assertSame($expected, $actual);  // Strict comparison
$this->assertNotEquals($expected, $actual);

// Boolean
$this->assertTrue($condition);
$this->assertFalse($condition);

// Null
$this->assertNull($value);
$this->assertNotNull($value);

// Empty/Count
$this->assertEmpty($array);
$this->assertNotEmpty($array);
$this->assertCount(3, $array);

// String
$this->assertStringContainsString('needle', $haystack);
$this->assertStringStartsWith('prefix', $string);
$this->assertStringEndsWith('suffix', $string);
$this->assertMatchesRegularExpression('/pattern/', $string);

// Array
$this->assertContains('value', $array);
$this->assertArrayHasKey('key', $array);
$this->assertArraySubset($subset, $array);

// Object
$this->assertInstanceOf(User::class, $object);
$this->assertObjectHasAttribute('property', $object);

// Exception
$this->expectException(\InvalidArgumentException::class);
$this->expectExceptionMessage('Invalid data');
```

### Custom Assertions

```php
// Add descriptive messages
$this->assertEquals(
    $expected,
    $actual,
    'User name should match expected value'
);

// Use assertThat for complex conditions
$this->assertThat(
    $value,
    $this->logicalAnd(
        $this->greaterThan(0),
        $this->lessThan(100)
    )
);
```

## Test Patterns

### AAA Pattern (Arrange-Act-Assert)

```php
public function testUserCreation(): void
{
    // Arrange - Set up test data
    $userData = [
        'name' => 'John Doe',
        'email' => 'john@example.com',
    ];

    // Act - Execute the code under test
    $user = $this->service->createUser($userData);

    // Assert - Verify the outcome
    $this->assertInstanceOf(User::class, $user);
    $this->assertEquals('John Doe', $user->getName());
    $this->assertEquals('john@example.com', $user->getEmail());
}
```

### Given-When-Then Pattern

```php
public function testUserLogin(): void
{
    // Given - Initial context
    $user = $this->createAuthenticatedUser();
    $credentials = ['email' => 'test@example.com', 'password' => 'secret'];

    // When - Event occurs
    $result = $this->service->login($credentials);

    // Then - Expected outcome
    $this->assertTrue($result->isSuccess());
    $this->assertEquals($user->getId(), $result->getUserId());
}
```

## Data Providers

### Basic Data Provider

```php
/**
 * @dataProvider validEmailProvider
 */
public function testValidateEmailWithValidData(string $email): void
{
    $result = $this->validator->validateEmail($email);
    $this->assertTrue($result);
}

public function validEmailProvider(): array
{
    return [
        'standard email' => ['user@example.com'],
        'subdomain' => ['user@mail.example.com'],
        'plus addressing' => ['user+tag@example.com'],
    ];
}
```

### Multiple Parameters

```php
/**
 * @dataProvider userDataProvider
 */
public function testUserValidation(string $name, int $age, bool $expectedResult): void
{
    $result = $this->validator->validate($name, $age);
    $this->assertEquals($expectedResult, $result);
}

public function userDataProvider(): array
{
    return [
        'valid user' => ['John Doe', 25, true],
        'empty name' => ['', 25, false],
        'negative age' => ['John Doe', -1, false],
        'too young' => ['John Doe', 15, false],
    ];
}
```

## Test Doubles

### Mocks

```php
public function testUserServiceCallsRepository(): void
{
    // Create mock
    $repository = $this->createMock(UserRepository::class);

    // Set expectations
    $repository->expects($this->once())
        ->method('findById')
        ->with(1)
        ->willReturn(new User(['id' => 1, 'name' => 'John']));

    // Inject mock
    $service = new UserService($repository);

    // Execute and assert
    $user = $service->getUser(1);
    $this->assertEquals('John', $user->getName());
}
```

### Stubs

```php
public function testUserServiceWithStub(): void
{
    // Create stub (no expectations)
    $repository = $this->createStub(UserRepository::class);

    // Configure return values
    $repository->method('findAll')
        ->willReturn([
            new User(['id' => 1, 'name' => 'John']),
            new User(['id' => 2, 'name' => 'Jane']),
        ]);

    $service = new UserService($repository);
    $users = $service->getAllUsers();

    $this->assertCount(2, $users);
}
```

### Spy

```php
public function testEventWasTriggered(): void
{
    // Create spy
    $eventDispatcher = $this->createMock(EventDispatcher::class);

    // Verify method was called
    $eventDispatcher->expects($this->once())
        ->method('dispatch')
        ->with($this->isInstanceOf(UserCreatedEvent::class));

    $service = new UserService($eventDispatcher);
    $service->createUser(['name' => 'John']);
}
```

## Test Documentation

### PHPDoc for Tests

```php
/**
 * Test user validation with invalid email
 *
 * Verifies that validation fails when email format is invalid
 *
 * @return void
 * @throws \Exception
 */
public function testValidateUserWithInvalidEmail(): void
{
    $this->expectException(\InvalidArgumentException::class);
    $this->validator->validate('invalid-email');
}
```

### Test Class Documentation

```php
/**
 * User Service Test
 *
 * Comprehensive tests for UserService class including:
 * - User creation and validation
 * - Email verification
 * - Password hashing
 * - User authentication
 *
 * @covers \App\Service\UserService
 * @uses \App\Repository\UserRepository
 * @uses \App\Entity\User
 */
class UserServiceTest extends TestCase
{
    // Test methods
}
```

## Test Organization

### Test File Structure

```
tests/
├── Unit/              # Unit tests (isolated, no dependencies)
│   ├── Service/
│   │   └── UserServiceTest.php
│   └── Entity/
│       └── UserTest.php
├── Integration/       # Integration tests (multiple components)
│   └── Repository/
│       └── UserRepositoryTest.php
└── Functional/        # Functional tests (end-to-end)
    └── Api/
        └── UserApiTest.php
```

### Test Categories

```php
/**
 * @group unit
 * @group user
 */
class UserServiceTest extends TestCase {}

/**
 * @group integration
 * @group database
 */
class UserRepositoryTest extends TestCase {}
```

## Coverage

### Code Coverage Requirements

```php
/**
 * @covers \App\Service\UserService::createUser
 * @covers \App\Service\UserService::validateUser
 */
class UserServiceTest extends TestCase {}
```

### Ignore from Coverage

```php
/**
 * @codeCoverageIgnore
 */
class DeprecatedClass {}

/**
 * @codeCoverageIgnore
 */
public function legacyMethod(): void {}
```

## Best Practices

### DO

```php
// ✅ Test one thing per test
public function testUserNameValidation(): void {}
public function testUserEmailValidation(): void {}

// ✅ Use descriptive test names
public function testValidateUserThrowsExceptionWhenEmailIsEmpty(): void {}

// ✅ Use data providers for similar test cases
/**
 * @dataProvider invalidEmailProvider
 */
public function testInvalidEmails(string $email): void {}

// ✅ Clean up in tearDown
protected function tearDown(): void {
    $this->cleanupTestData();
    parent::tearDown();
}
```

### DON'T

```php
// ❌ Test multiple things in one test
public function testEverything(): void {
    $this->testValidation();
    $this->testCreation();
    $this->testDeletion();
}

// ❌ Use generic test names
public function testMethod1(): void {}

// ❌ Leave test data
public function testWithoutCleanup(): void {
    // Creates test data but never cleans up
}

// ❌ Skip tests without reason
public function testSomething(): void {
    $this->markTestSkipped();  // Why?
}
```

## Test Execution Environment

### Docker-Based Test Execution (Recommended)

**ALWAYS use Docker containers for PHP tests** to ensure consistent PHP version and environment:

```bash
# ✅ CORRECT: Docker-based execution
docker compose -f docker-compose.test.yml run --rm web

# With specific test file
TEST_ONLY="./tests/TestCase/Service/UserServiceTest.php" \
docker compose -f docker-compose.test.yml run --rm web

# With specific test method
TEST_ONLY="--filter testMethodName ./tests/TestCase/Service/UserServiceTest.php" \
docker compose -f docker-compose.test.yml run --rm web
```

**Why Docker execution is critical:**
- Ensures consistent PHP version across all environments
- Avoids version mismatch between local and CI/CD
- Guarantees same database configuration
- Prevents environment-specific test failures

### Prohibited Execution Methods

```bash
# ❌ WRONG: Direct localhost execution
vendor/bin/phpunit

# ❌ WRONG: Composer shortcut (unless explicitly configured)
composer test

# ❌ WRONG: Direct PHPUnit without container
php vendor/bin/phpunit
```

### Pre-Execution Checklist

Before running tests, verify:
1. `docker-compose.test.yml` exists in project root
2. `Dockerfile` or `Dockerfile.test` specifies correct PHP version
3. Check `tests/README.md` for project-specific instructions
4. Verify test database configuration

### Environment Configuration

```yaml
# docker-compose.test.yml example
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - DB_HOST=db
      - DB_DATABASE=test_database
      - PHP_VERSION=8.2  # Match project requirements
    volumes:
      - ./:/app
    depends_on:
      - db
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: test_database
```

## Framework-Agnostic

These standards apply to:
- CakePHP with PHPUnit
- Laravel with PHPUnit
- Symfony with PHPUnit
- Any PHP project using PHPUnit

Framework-specific testing patterns (Fixtures, TestCase extensions, etc.) should be defined in framework-level skills (e.g., `php-cakephp/testing-conventions`).
