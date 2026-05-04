package com.example.employeeapi.repository;

import com.example.employeeapi.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    Optional<Employee> findByEmail(String email);

    List<Employee> findByDepartment(String department);

    Page<Employee> findByDepartment(String department, Pageable pageable);

    List<Employee> findByDesignation(String designation);

    boolean existsByEmail(String email);

    /**
     * Search employees by keyword across first name, last name,
     * email, department, and designation (case-insensitive).
     */
    @Query("SELECT e FROM Employee e WHERE " +
           "LOWER(e.firstName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.lastName) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.email) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.department) LIKE LOWER(CONCAT('%', :search, '%')) OR " +
           "LOWER(e.designation) LIKE LOWER(CONCAT('%', :search, '%'))")
    Page<Employee> searchEmployees(@Param("search") String search, Pageable pageable);
}
