package com.example.employeeapi.service;

import com.example.employeeapi.dto.EmployeeDto;
import com.example.employeeapi.entity.Employee;
import com.example.employeeapi.exception.ResourceNotFoundException;
import com.example.employeeapi.repository.EmployeeRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeRepository employeeRepository;

    public EmployeeServiceImpl(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    @Override
    public EmployeeDto createEmployee(EmployeeDto dto) {
        if (employeeRepository.existsByEmail(dto.getEmail())) {
            throw new RuntimeException("Employee with email '" + dto.getEmail() + "' already exists");
        }
        Employee employee = mapToEntity(dto);
        Employee saved = employeeRepository.save(employee);
        return mapToDto(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public EmployeeDto getEmployeeById(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee", "id", id));
        return mapToDto(employee);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EmployeeDto> getAllEmployees() {
        return employeeRepository.findAll()
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EmployeeDto> getAllEmployees(Pageable pageable, String search) {
        Page<Employee> page;
        if (search != null && !search.trim().isEmpty()) {
            page = employeeRepository.searchEmployees(search.trim(), pageable);
        } else {
            page = employeeRepository.findAll(pageable);
        }
        return page.map(this::mapToDto);
    }

    @Override
    public EmployeeDto updateEmployee(Long id, EmployeeDto dto) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee", "id", id));

        employee.setFirstName(dto.getFirstName());
        employee.setLastName(dto.getLastName());
        employee.setEmail(dto.getEmail());
        employee.setPhoneNumber(dto.getPhoneNumber());
        employee.setDepartment(dto.getDepartment());
        employee.setDesignation(dto.getDesignation());
        employee.setSalary(dto.getSalary());
        employee.setHireDate(dto.getHireDate());

        Employee updated = employeeRepository.save(employee);
        return mapToDto(updated);
    }

    @Override
    public void deleteEmployee(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee", "id", id));
        employeeRepository.delete(employee);
    }

    @Override
    @Transactional(readOnly = true)
    public List<EmployeeDto> getEmployeesByDepartment(String department) {
        return employeeRepository.findByDepartment(department)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EmployeeDto> getEmployeesByDepartment(String department, Pageable pageable) {
        return employeeRepository.findByDepartment(department, pageable)
                .map(this::mapToDto);
    }

    // ==================== Mapper Methods ====================

    private EmployeeDto mapToDto(Employee employee) {
        EmployeeDto dto = new EmployeeDto();
        dto.setId(employee.getId());
        dto.setFirstName(employee.getFirstName());
        dto.setLastName(employee.getLastName());
        dto.setEmail(employee.getEmail());
        dto.setPhoneNumber(employee.getPhoneNumber());
        dto.setDepartment(employee.getDepartment());
        dto.setDesignation(employee.getDesignation());
        dto.setSalary(employee.getSalary());
        dto.setHireDate(employee.getHireDate());
        return dto;
    }

    private Employee mapToEntity(EmployeeDto dto) {
        Employee employee = new Employee();
        employee.setFirstName(dto.getFirstName());
        employee.setLastName(dto.getLastName());
        employee.setEmail(dto.getEmail());
        employee.setPhoneNumber(dto.getPhoneNumber());
        employee.setDepartment(dto.getDepartment());
        employee.setDesignation(dto.getDesignation());
        employee.setSalary(dto.getSalary());
        employee.setHireDate(dto.getHireDate());
        return employee;
    }
}
