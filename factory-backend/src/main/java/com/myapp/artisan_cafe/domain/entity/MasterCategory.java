package com.myapp.artisan_cafe.domain.entity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;
@Entity
@Table(name = "master_categories")
@Data
public class MasterCategory {
    @Id
    private String categoryCode;
    private String categoryName;
}