package com.myapp.artisan_cafe.datasource;

import org.springframework.stereotype.Service;

@Service
public class DataSourceService {

    public void updateDataSource(String dbName) {
        if (dbName != null && !dbName.isEmpty()) {

            System.out.println("Switching context to Database: " + dbName);
        }
    }
}