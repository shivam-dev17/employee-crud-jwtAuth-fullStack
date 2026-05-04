package com.example.employeeapi.controller;

import com.example.employeeapi.dto.ApiResponse;
import com.example.employeeapi.dto.EmployeeDto;
import com.example.employeeapi.dto.PaginatedResponse;
import com.example.employeeapi.service.EmployeeService;
import com.example.employeeapi.service.ExportService;
import jakarta.validation.Valid;
import org.springframework.core.io.InputStreamResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/employees")
@CrossOrigin(origins = "http://localhost:3000")
public class EmployeeController {

        private final EmployeeService employeeService;
        private final ExportService exportService;

        public EmployeeController(EmployeeService employeeService,
                        ExportService exportService) {
                this.employeeService = employeeService;
                this.exportService = exportService;
        }

        // ==================== CRUD Endpoints ====================

        @PostMapping
        public ResponseEntity<ApiResponse<EmployeeDto>> createEmployee(
                        @Valid @RequestBody EmployeeDto employeeDto) {
                EmployeeDto created = employeeService.createEmployee(employeeDto);
                return ResponseEntity.status(HttpStatus.CREATED)
                                .body(new ApiResponse<>(true, "Employee created successfully", created));
        }

        @GetMapping
        public ResponseEntity<ApiResponse<List<EmployeeDto>>> getAllEmployees() {
                List<EmployeeDto> employees = employeeService.getAllEmployees();
                return ResponseEntity.ok(new ApiResponse<>(true, "Employees fetched successfully", employees));
        }

        @GetMapping("/{id}")
        public ResponseEntity<ApiResponse<EmployeeDto>> getEmployeeById(@PathVariable Long id) {
                EmployeeDto employee = employeeService.getEmployeeById(id);
                return ResponseEntity.ok(new ApiResponse<>(true, "Employee fetched successfully", employee));
        }

        @PutMapping("/{id}")
        public ResponseEntity<ApiResponse<EmployeeDto>> updateEmployee(
                        @PathVariable Long id, @Valid @RequestBody EmployeeDto employeeDto) {
                EmployeeDto updated = employeeService.updateEmployee(id, employeeDto);
                return ResponseEntity.ok(new ApiResponse<>(true, "Employee updated successfully", updated));
        }

        @DeleteMapping("/{id}")
        public ResponseEntity<ApiResponse<Object>> deleteEmployee(@PathVariable Long id) {
                employeeService.deleteEmployee(id);
                return ResponseEntity.ok(new ApiResponse<>(true, "Employee deleted successfully"));
        }

        @GetMapping("/department/{department}")
        public ResponseEntity<ApiResponse<List<EmployeeDto>>> getByDepartment(
                        @PathVariable String department) {
                List<EmployeeDto> employees = employeeService.getEmployeesByDepartment(department);
                return ResponseEntity.ok(new ApiResponse<>(true, "Employees fetched by department", employees));
        }

        // ==================== Paginated Endpoints ====================

        /**
         * GET /api/employees/page?page=0&size=10&sortBy=id&sortDir=asc&search=john
         *
         * Returns a paginated list of employees with optional search keyword.
         */
        @GetMapping("/page")
        public ResponseEntity<PaginatedResponse<EmployeeDto>> getAllEmployeesPaginated(
                        @RequestParam(value = "page", defaultValue = "0") int page,
                        @RequestParam(value = "size", defaultValue = "10") int size,
                        @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
                        @RequestParam(value = "sortDir", defaultValue = "asc") String sortDir,
                        @RequestParam(value = "search", required = false) String search) {

                Sort sort = sortDir.equalsIgnoreCase("desc")
                                ? Sort.by(sortBy).descending()
                                : Sort.by(sortBy).ascending();

                Pageable pageable = PageRequest.of(page, size, sort);
                Page<EmployeeDto> employeePage = employeeService.getAllEmployees(pageable, search);

                PaginatedResponse<EmployeeDto> response = new PaginatedResponse<>(
                                true,
                                "Employees fetched successfully",
                                employeePage.getContent(),
                                employeePage.getNumber(),
                                employeePage.getSize(),
                                employeePage.getTotalElements(),
                                employeePage.getTotalPages(),
                                employeePage.isFirst(),
                                employeePage.isLast());

                return ResponseEntity.ok(response);
        }

        /**
         * GET
         * /api/employees/department/{department}/page?page=0&size=10&sortBy=id&sortDir=asc
         *
         * Returns a paginated list of employees filtered by department.
         */
        @GetMapping("/department/{department}/page")
        public ResponseEntity<PaginatedResponse<EmployeeDto>> getByDepartmentPaginated(
                        @PathVariable String department,
                        @RequestParam(value = "page", defaultValue = "0") int page,
                        @RequestParam(value = "size", defaultValue = "10") int size,
                        @RequestParam(value = "sortBy", defaultValue = "id") String sortBy,
                        @RequestParam(value = "sortDir", defaultValue = "asc") String sortDir) {

                Sort sort = sortDir.equalsIgnoreCase("desc")
                                ? Sort.by(sortBy).descending()
                                : Sort.by(sortBy).ascending();

                Pageable pageable = PageRequest.of(page, size, sort);
                Page<EmployeeDto> employeePage = employeeService.getEmployeesByDepartment(department, pageable);

                PaginatedResponse<EmployeeDto> response = new PaginatedResponse<>(
                                true,
                                "Employees fetched by department (paginated)",
                                employeePage.getContent(),
                                employeePage.getNumber(),
                                employeePage.getSize(),
                                employeePage.getTotalElements(),
                                employeePage.getTotalPages(),
                                employeePage.isFirst(),
                                employeePage.isLast());

                return ResponseEntity.ok(response);
        }

        // ==================== Export / Download Endpoints ====================

        /**
         * GET /api/employees/export/csv
         *
         * Downloads all employee data as a CSV file.
         */
        @GetMapping("/export/csv")
        public ResponseEntity<InputStreamResource> exportCsv() {
                String filename = "employees_" +
                                LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".csv";

                ByteArrayInputStream stream = exportService.exportToCsv();

                return ResponseEntity.ok()
                                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                                .contentType(MediaType.parseMediaType("text/csv"))
                                .body(new InputStreamResource(stream));
        }

        /**
         * GET /api/employees/export/excel
         *
         * Downloads all employee data as an XLSX (Excel) file.
         */
        @GetMapping("/export/excel")
        public ResponseEntity<InputStreamResource> exportExcel() throws IOException {
                String filename = "employees_" +
                                LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd")) + ".xlsx";

                ByteArrayInputStream stream = exportService.exportToExcel();

                return ResponseEntity.ok()
                                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                                .contentType(MediaType.parseMediaType(
                                                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                                .body(new InputStreamResource(stream));
        }
}
