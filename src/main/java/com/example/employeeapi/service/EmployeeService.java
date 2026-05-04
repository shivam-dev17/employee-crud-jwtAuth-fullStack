package com.example.employeeapi.service;

import com.example.employeeapi.dto.EmployeeDto;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface EmployeeService {

    EmployeeDto createEmployee(EmployeeDto employeeDto);

    EmployeeDto getEmployeeById(Long id);

    List<EmployeeDto> getAllEmployees();

    /** Paginated list of all employees with optional search. */
    Page<EmployeeDto> getAllEmployees(Pageable pageable, String search);

    EmployeeDto updateEmployee(Long id, EmployeeDto employeeDto);

    void deleteEmployee(Long id);

    List<EmployeeDto> getEmployeesByDepartment(String department);

    /** Paginated list of employees filtered by department. */
    Page<EmployeeDto> getEmployeesByDepartment(String department, Pageable pageable);
}
