# DailyFixer

DailyFixer is a Jakarta EE web application that connects customers with service technicians for home repair and maintenance services. The platform also includes an integrated store for parts and supplies.

## Tech Stack

### Backend
- **Java**: Version 17 LTS
- **Jakarta EE**: Version 10
  - Jakarta Servlet API 6.1.0
  - Jakarta JSTL 3.0.0
- **Database**: MySQL 8.0 (production), H2 2.3.232 (testing)
- **Persistence**: JDBC (no JPA/Hibernate)
- **Dependency Injection**: None (plain servlets)
- **Email**: Jakarta Mail 2.0.2
- **Payment Gateway**: PayHere integration

### Build & Testing
- **Build Tool**: Maven
- **Testing Framework**: JUnit 5 (Jupiter) 5.11.0
- **Mocking**: Mockito 5.14.2
- **Test Database**: H2 in-memory database
- **Code Coverage**: JaCoCo 0.8.12
- **Unit Tests**: Maven Surefire Plugin 3.2.5
- **Integration Tests**: Maven Failsafe Plugin 3.2.5

### Architecture
- **Pattern**: DAO (Data Access Object) pattern with plain JDBC
- **Packaging**: WAR (Web Application Archive)
- **Server**: Compatible with Jakarta EE 10 servers (TomEE, Payara, WildFly, GlassFish)

## Project Structure

```
dailyfixer/
├── src/
│   ├── main/
│   │   ├── java/com/dailyfixer/
│   │   │   ├── dao/              # Data Access Objects
│   │   │   ├── model/            # Domain models
│   │   │   ├── servlet/          # HTTP Servlets
│   │   │   ├── service/          # Service layer
│   │   │   ├── product/          # Product management
│   │   │   ├── store/            # Store functionality
│   │   │   ├── user/             # User management
│   │   │   ├── discount/         # Discount management
│   │   │   ├── util/             # Utility classes
│   │   │   └── config/           # Configuration
│   │   ├── resources/            # SQL schemas and config
│   │   └── webapp/               # Web resources (JSP, HTML, CSS)
│   └── test/
│       ├── java/com/dailyfixer/
│       │   ├── dao/              # DAO tests
│       │   └── util/             # Test utilities
│       └── resources/            # Test resources
└── pom.xml
```

## Testing

This project includes comprehensive unit and integration tests using JUnit 5 and H2 in-memory database.

### Running Tests

#### Quick Reference

| Command | What it does | Time | Generates Report |
|---------|-------------|------|------------------|
| `mvn test` | Run unit tests only | ~7s | No (creates jacoco.exec) |
| `mvn verify` | Run all tests (unit + integration) | ~9s | Yes (auto-generated) |
| `mvn jacoco:report` | Generate coverage report from existing data | ~2s | Yes (from jacoco.exec) |

#### Run Unit Tests Only
```bash
mvn test
```
This runs all tests in classes ending with `*Test.java`.

#### Run Integration Tests Only
```bash
mvn verify
```
This runs all tests in classes ending with `*IT.java`.

#### Run All Tests (Unit + Integration)
```bash
mvn clean verify
```

#### Generate Code Coverage Report
There are two ways to generate coverage reports:

**Option 1: Generate report while running tests**
```bash
mvn clean verify
```
This runs all tests and automatically generates the JaCoCo report.

**Option 2: Generate report from previous test run (without re-running tests)**
```bash
mvn jacoco:report
```
This generates the HTML report from the existing `target/jacoco.exec` file created by a previous test run. This is much faster as it doesn't re-execute tests.

**Typical workflow:**
```bash
# First time: Run tests (creates jacoco.exec)
mvn test

# Later: Regenerate report without re-running tests
mvn jacoco:report
```

### Test Reports

After running tests, reports are generated in the following locations:

- **Surefire Reports** (Unit Tests): `target/surefire-reports/`
  - HTML report: `target/surefire-reports/index.html`
  - XML reports for CI integration

- **Failsafe Reports** (Integration Tests): `target/failsafe-reports/`

- **JaCoCo Coverage Report**: `target/site/jacoco/`
  - Open `target/site/jacoco/index.html` in a browser to view coverage

#### Fast Report Regeneration

**Key Feature:** You can regenerate the JaCoCo HTML coverage report without re-running tests!

Once you've run tests at least once (which creates `target/jacoco.exec`), you can regenerate the HTML report instantly:

```bash
# Run tests once (takes ~7 seconds)
mvn test

# Regenerate report anytime (takes ~2 seconds)
mvn jacoco:report
```

**Use cases:**
- Quickly view coverage after modifying code
- Share updated reports with team without waiting for full test suite
- Generate reports in different formats without test overhead
- Useful during development when you want to check coverage frequently

**Note:** The report reflects the last test execution. To update coverage data, re-run `mvn test` or `mvn verify`.

### Test Structure

#### Unit Tests
- Located in: `src/test/java/`
- Naming convention: `*Test.java`
- Examples:
  - `UserDAOTest.java` - Tests for user registration, login validation
  - `ServiceDAOTest.java` - Tests for service CRUD operations

#### Integration Tests
- Located in: `src/test/java/`
- Naming convention: `*IT.java`
- Examples:
  - `DatabaseIntegrationIT.java` - End-to-end database workflows

#### Test Database
- Tests use H2 in-memory database (`jdbc:h2:mem:dailyfixer_test`)
- H2 is configured to run in MySQL compatibility mode
- Test schema is automatically initialized via `TestDBConnection`
- Each test method runs with a clean database state

## Development

### Prerequisites
- Java 17 or higher
- Maven 3.8+
- MySQL 8.0 (for production deployment)
- Jakarta EE 10 compatible server (TomEE, Payara, or WildFly)

### Building the Project

```bash
# Clean and compile
mvn clean compile

# Package as WAR file
mvn clean package

# Skip tests during build
mvn package -DskipTests
```

The WAR file will be generated in `target/dailyfixer-1.0-SNAPSHOT.war`.

### Database Setup

1. Create MySQL database:
```sql
CREATE DATABASE dfguidestore;
```

2. Update database credentials in `src/main/java/com/dailyfixer/util/DBConnection.java`:
```java
private static final String URL = "jdbc:mysql://localhost:3306/dfguidestore";
private static final String USER = "your_username";
private static final String PASS = "your_password";
```

3. Run the schema from `src/main/resources/`

### Configuration

Production configuration is in `src/main/resources/config.properties`:
- Database connection settings
- PayHere payment gateway configuration
- Application URLs

**Note**: Do not commit sensitive credentials to version control.

## Continuous Integration

GitHub Actions workflow automatically runs on every push and pull request:
- Checks out code
- Sets up Java 17 (Temurin distribution)
- Runs unit tests (`mvn test`)
- Runs integration tests (`mvn verify`)
- Generates and uploads test reports
- Generates and uploads JaCoCo coverage report

See `.github/workflows/tests.yml` for CI configuration.

## Features

- **User Management**: Registration, login, profile management
- **Technician Services**: Service listing, booking management
- **Store Integration**: Product catalog, shopping cart, orders
- **Payment Processing**: PayHere payment gateway integration
- **Guides & Tutorials**: DIY repair guides
- **Reviews & Ratings**: Service and guide rating system
- **Discount Management**: Promotional codes and discounts

## Contributing

When contributing:
1. Write tests for new features
2. Ensure all tests pass: `mvn clean verify`
3. Maintain code coverage above 70%
4. Follow existing code style and patterns

## License

[Add license information here]

## Contact

[Add contact information here]
