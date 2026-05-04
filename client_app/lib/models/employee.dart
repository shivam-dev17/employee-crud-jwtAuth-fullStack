class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? department;
  final String? designation;
  final double? salary;
  final String? hireDate;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.department,
    this.designation,
    this.salary,
    this.hireDate,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      department: json['department'],
      designation: json['designation'],
      salary: json['salary']?.toDouble(),
      hireDate: json['hireDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'department': department,
      'designation': designation,
      'salary': salary,
      'hireDate': hireDate,
    };
  }

  Employee copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? department,
    String? designation,
    double? salary,
    String? hireDate,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      salary: salary ?? this.salary,
      hireDate: hireDate ?? this.hireDate,
    );
  }
}
