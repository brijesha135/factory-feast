package com.myapp.artisan_cafe.domain.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "master_variants")
@Data
public class MasterVariant {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer variantId;

    private Integer skuCode; // Links to menu_catalog.sku_code
    private String variantName;
    private Double additionalPrice;
}
