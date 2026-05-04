package com.example.employeeapi.service;

import com.example.employeeapi.entity.Employee;
import com.example.employeeapi.repository.EmployeeRepository;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Service responsible for exporting employee data into
 * downloadable file formats (CSV and XLSX).
 */
@Service
@Transactional(readOnly = true)
public class ExportService {

    private final EmployeeRepository employeeRepository;

    private static final String[] HEADERS = {
            "ID", "First Name", "Last Name", "Email",
            "Phone Number", "Department", "Designation",
            "Salary", "Hire Date"
    };

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public ExportService(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    // ==================== CSV Export ====================

    /**
     * Generates a CSV byte stream of all employee data.
     */
    public ByteArrayInputStream exportToCsv() {
        List<Employee> employees = employeeRepository.findAll();

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        // Header row
        pw.println(String.join(",", HEADERS));

        // Data rows
        for (Employee emp : employees) {
            pw.println(String.join(",",
                    safe(emp.getId()),
                    escapeCsv(emp.getFirstName()),
                    escapeCsv(emp.getLastName()),
                    escapeCsv(emp.getEmail()),
                    escapeCsv(emp.getPhoneNumber()),
                    escapeCsv(emp.getDepartment()),
                    escapeCsv(emp.getDesignation()),
                    safe(emp.getSalary()),
                    emp.getHireDate() != null ? emp.getHireDate().format(DATE_FMT) : ""
            ));
        }

        pw.flush();
        return new ByteArrayInputStream(sw.toString().getBytes());
    }

    // ==================== XLSX Export ====================

    /**
     * Generates an XLSX (Excel) byte stream of all employee data
     * with styled headers and auto-sized columns.
     */
    public ByteArrayInputStream exportToExcel() throws IOException {
        List<Employee> employees = employeeRepository.findAll();

        try (XSSFWorkbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Employees");

            // ---- Header style ----
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setFontHeightInPoints((short) 12);
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setBorderBottom(BorderStyle.THIN);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);

            // ---- Data cell style ----
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);

            // ---- Header row ----
            Row headerRow = sheet.createRow(0);
            for (int col = 0; col < HEADERS.length; col++) {
                Cell cell = headerRow.createCell(col);
                cell.setCellValue(HEADERS[col]);
                cell.setCellStyle(headerStyle);
            }

            // ---- Data rows ----
            int rowIdx = 1;
            for (Employee emp : employees) {
                Row row = sheet.createRow(rowIdx++);

                createCell(row, 0, emp.getId() != null ? emp.getId().doubleValue() : 0, dataStyle);
                createCell(row, 1, emp.getFirstName(), dataStyle);
                createCell(row, 2, emp.getLastName(), dataStyle);
                createCell(row, 3, emp.getEmail(), dataStyle);
                createCell(row, 4, emp.getPhoneNumber(), dataStyle);
                createCell(row, 5, emp.getDepartment(), dataStyle);
                createCell(row, 6, emp.getDesignation(), dataStyle);
                createCell(row, 7, emp.getSalary() != null ? emp.getSalary() : 0.0, dataStyle);
                createCell(row, 8,
                        emp.getHireDate() != null ? emp.getHireDate().format(DATE_FMT) : "",
                        dataStyle);
            }

            // Auto-size columns
            for (int col = 0; col < HEADERS.length; col++) {
                sheet.autoSizeColumn(col);
            }

            workbook.write(out);
            return new ByteArrayInputStream(out.toByteArray());
        }
    }

    // ==================== Helper Methods ====================

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private void createCell(Row row, int col, double value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value);
        cell.setCellStyle(style);
    }

    private String safe(Object value) {
        return value != null ? value.toString() : "";
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        // Wrap in quotes if it contains comma, quote, or newline
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
