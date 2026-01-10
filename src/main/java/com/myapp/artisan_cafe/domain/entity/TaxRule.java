package com.myapp.artisan_cafe.domain.entity;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "tax_rules")
@Data
public class TaxRule {
    @Id
    private String ruleCode;
    private String label;
    private Double percentage;
    private String indicatorGroup; // This links to MenuCatalog.taxIndicator
}
