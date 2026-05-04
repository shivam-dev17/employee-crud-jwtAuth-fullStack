# Employee Management System - Full Stack Application

A comprehensive full-stack employee management system featuring role-based JWT authentication, built with modern technologies for secure and scalable operations.

## 📋 Overview

This application provides a complete solution for managing employee records with enterprise-grade security. It combines a robust Spring Boot backend with a responsive Flutter web frontend, enabling seamless employee CRUD operations with role-based access control.

**Key Features:**
- ✅ JWT-based authentication and authorization
- ✅ Role-based access control (RBAC)
- ✅ Complete employee CRUD operations
- ✅ Secure API endpoints
- ✅ Responsive web interface
- ✅ Oracle database integration

## 🏗️ Architecture

### Tech Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Frontend** | Flutter (Dart) | Latest |
| **Backend** | Spring Boot (Java) | - |
| **Database** | Oracle DB | - |
| **Authentication** | JWT (JSON Web Tokens) | - |

### Project Structure

```
employee-crud-jwtAuth-fullStack/
├── server/                 # Spring Boot Backend
│   ├── src/
│   ├── pom.xml
│   └── application.properties
├── client_app/            # Flutter Web Frontend
│   ├── lib/
│   ├── pubspec.yaml
│   └── web/
└── README.md
```

## 🚀 Quick Start

### Prerequisites

- **Java Development Kit (JDK)** 11 or higher
- **Flutter SDK** 3.0 or higher
- **Oracle Database** (configured and running)
- **Git** for version control
- **Maven** (for Spring Boot backend)

### Backend Setup (Spring Boot)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shivam-dev17/employee-crud-jwtAuth-fullStack.git
   cd employee-crud-jwtAuth-fullStack/server
   ```

2. **Configure the database:**
   - Update `application.properties` with your Oracle database credentials:
     ```properties
     spring.datasource.url=jdbc:oracle:thin:@localhost:1521:xe
     spring.datasource.username=your_username
     spring.datasource.password=your_password
     spring.jpa.hibernate.ddl-auto=update
     ```

3. **Install dependencies:**
   ```bash
   mvn clean install
   ```

4. **Run the Spring Boot server:**
   ```bash
   mvn spring-boot:run
   ```
   
   The backend API will be available at: **`http://localhost:8080`**

### Frontend Setup (Flutter Web)

1. **Navigate to the Flutter project:**
   ```bash
   cd client_app
   ```

2. **Get Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint:**
   - Update the API base URL in your Flutter app configuration to point to the backend:
     ```dart
     const String API_BASE_URL = 'http://localhost:8080/api';
     ```

4. **Run the Flutter web application:**
   ```bash
   flutter run -d chrome
   ```
   
   The frontend will be available at: **`http://localhost:3000`**

## 🔐 Authentication & Security

### JWT Implementation

The application uses JWT (JSON Web Tokens) for stateless authentication:

- **Token Generation:** Issued upon successful login
- **Token Validation:** Every protected endpoint validates the JWT
- **Token Expiration:** Configure token expiration in backend settings
- **Refresh Mechanism:** Support for token refresh to maintain session

### Role-Based Access Control (RBAC)

Users are assigned roles that determine their access levels:

- **Admin:** Full access to all operations
- **Manager:** Can view and manage employee records
- **User:** Limited read-only access

## 📡 API Endpoints

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | User registration |
| POST | `/api/auth/refresh` | Refresh JWT token |
| POST | `/api/auth/logout` | User logout |

### Employee Management Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/employees` | Get all employees |
| GET | `/api/employees/{id}` | Get employee by ID |
| POST | `/api/employees` | Create new employee |
| PUT | `/api/employees/{id}` | Update employee |
| DELETE | `/api/employees/{id}` | Delete employee |

*Note: All endpoints (except auth) require valid JWT token in Authorization header*

## 📦 Dependencies

### Backend (Spring Boot)
- Spring Boot Web
- Spring Security
- Spring Data JPA
- JWT Library (jjwt)
- Oracle JDBC Driver

### Frontend (Flutter)
- flutter/material.dart
- http (for API calls)
- shared_preferences (for token storage)
- provider (for state management)

## 🔧 Configuration

### Backend Configuration

Update `application.properties`:

```properties
# Server Configuration
server.port=8080
server.servlet.context-path=/api

# Database Configuration
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:xe
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.Oracle10gDialect

# JWT Configuration
jwt.secret=your_secret_key_here
jwt.expiration=3600000
```

### Frontend Configuration

Update your Flutter configuration in `main.dart`:

```dart
const String API_BASE_URL = 'http://localhost:8080/api';
const String TOKEN_KEY = 'jwt_token';
```

## 📝 Usage

1. **Start the backend** on port 8080
2. **Start the frontend** on port 3000
3. **Navigate to** `http://localhost:3000` in your browser
4. **Login** with your credentials
5. **Perform CRUD operations** based on your role permissions

## 🛠️ Development

### Building for Production

**Backend:**
```bash
cd server
mvn clean package
# Deploy the generated .war or .jar file
```

**Frontend:**
```bash
cd client_app
flutter build web --release
# Output will be in build/web/
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Backend won't start | Verify Oracle DB is running and credentials are correct |
| CORS errors | Check CORS configuration in Spring Security |
| JWT token invalid | Ensure token expiration is properly configured |
| Flutter can't connect to API | Verify backend is running on port 8080 and firewall allows connection |
| Port 3000 already in use | Use `flutter run -d chrome --web-port 3001` to use a different port |

## 📚 Documentation

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Flutter Documentation](https://flutter.dev/docs)
- [JWT.io](https://jwt.io/)
- [Oracle Database Documentation](https://docs.oracle.com/en/database/)

## 📄 License

This project is open source and available under the MIT License.

## 👨‍💻 Author

**Shivam Dev**
- GitHub: [@shivam-dev17](https://github.com/shivam-dev17)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues or questions:
1. Check existing GitHub issues
2. Create a new issue with detailed description
3. Include error logs and steps to reproduce

---

**Last Updated:** May 2026

Made with ❤️ for Enterprise Employee Management
