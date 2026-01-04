package com.myapp.artisan_cafe.controller;

import com.myapp.artisan_cafe.datasource.DataSourceService;
import com.myapp.artisan_cafe.domain.entity.*;
import com.myapp.artisan_cafe.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
@CrossOrigin
public class CatalogController {

    private final DataSourceService dataSourceService;
    private final MenuCatalogRepository productRepo;
    private final CategoryRepository categoryRepo; // Corrected injection
    private final MasterModifierRepository modifierRepo;
    private final MasterVariantRepository variantRepo;
    private final TaxRuleRepository taxRepo;
    @GetMapping("/products/getAll")
    public ResponseEntity<List<MenuCatalog>> getAllProducts(@RequestParam String DB) {
        dataSourceService.updateDataSource(DB);
        return ResponseEntity.ok(productRepo.findAll());
    }

    @GetMapping("/category/getAll")
    public ResponseEntity<List<MasterCategory>> getAllCategories(@RequestParam String DB) {
        dataSourceService.updateDataSource(DB);
        return ResponseEntity.ok(categoryRepo.findAll());
    }
    @GetMapping("/modifiers/getAll")
    public ResponseEntity<List<MasterModifier>> getAllModifiers(@RequestParam String DB) {
        dataSourceService.updateDataSource(DB);
        return ResponseEntity.ok(modifierRepo.findAll());
    }

    @GetMapping("/variants/{sku}")
    public ResponseEntity<List<MasterVariant>> getVariantsBySku(@PathVariable Integer sku, @RequestParam String DB) {
        dataSourceService.updateDataSource(DB);
        return ResponseEntity.ok(variantRepo.findBySkuCode(sku));
    }
    @GetMapping("/taxes/{indicator}")
    public ResponseEntity<List<TaxRule>> getTaxesByIndicator(@PathVariable String indicator, @RequestParam String DB) {
        dataSourceService.updateDataSource(DB);
        return ResponseEntity.ok(taxRepo.findByIndicatorGroup(indicator));
    }
}