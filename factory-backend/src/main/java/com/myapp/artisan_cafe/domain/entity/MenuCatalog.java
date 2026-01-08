package com.myapp.artisan_cafe.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "menu_catalog")
@Data
@NoArgsConstructor
public class MenuCatalog {
    @Id
    private Integer skuCode;

    @Column(name = "product_display_name")
    private String productName;

    private String categoryCode;
    private Double baseFactoryPrice;
    private String taxIndicator;
    private String kitchenStationCode;
}