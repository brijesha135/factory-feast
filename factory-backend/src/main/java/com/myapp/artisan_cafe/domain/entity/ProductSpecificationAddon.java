package com.myapp.artisan_cafe.domain.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_specification_addons")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductSpecificationAddon {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long customId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "entry_id")
    @JsonBackReference
    private ProductionLineItem lineItem;

    private String modifierCode;
    private String modifierLabel;
    private Double upchargePrice;
}