package com.myapp.artisan_cafe.domain.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "production_line_items")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ProductionLineItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long entryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "manifest_id")
    @JsonBackReference
    private FactoryOrderManifest manifest;

    private String productSku;
    private String itemDescription;
    private String menuCategory;
    private Integer receiveQty;
    private Integer dispatchQty;
    private Double unitBasePrice;
    private Double grossLineTotal;

    @Column(columnDefinition = "TEXT")
    private String taxDataJson;

    // This links to the third file below
    @OneToMany(mappedBy = "lineItem", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonBackReference
    private List<ProductSpecificationAddon> addons;
}