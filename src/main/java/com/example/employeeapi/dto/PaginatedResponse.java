package com.example.employeeapi.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PaginatedResponse<T> {

    private boolean success;
    private String message;
    private List<T> data;
    private int pageNumber;
    private int pageSize;
    private long totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
    private LocalDateTime timestamp = LocalDateTime.now();

    public PaginatedResponse(boolean success, String message, List<T> data,
                             int pageNumber, int pageSize, long totalElements,
                             int totalPages, boolean first, boolean last) {
        this.success = success;
        this.message = message;
        this.data = data;
        this.pageNumber = pageNumber;
        this.pageSize = pageSize;
        this.totalElements = totalElements;
        this.totalPages = totalPages;
        this.first = first;
        this.last = last;
        this.timestamp = LocalDateTime.now();
    }
}
