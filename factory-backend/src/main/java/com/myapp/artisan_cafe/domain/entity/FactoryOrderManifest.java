package com.myapp.artisan_cafe.domain.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "factory_order_manifests")
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class FactoryOrderManifest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long manifestId;

    @Column(name = "manifest_no", unique = true)
    private String manifestNo;

    private String licenseKey;
    private String outletBrand;
    private String fulfillmentType;
    private String manifestDate;
    private String manifestTime;
    private String workflowStatus;
    private String chefInstructions;

    @OneToMany(mappedBy = "manifest", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonManagedReference
    private List<ProductionLineItem> items;
}