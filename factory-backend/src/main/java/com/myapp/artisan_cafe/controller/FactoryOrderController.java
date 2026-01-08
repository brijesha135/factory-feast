package com.myapp.artisan_cafe.controller;

import com.myapp.artisan_cafe.datasource.DataSourceService;
import com.myapp.artisan_cafe.domain.entity.FactoryOrderManifest;
import com.myapp.artisan_cafe.dto.FactoryOrderRequestDTO;
import com.myapp.artisan_cafe.service.FactoryOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/factory/orders")
@RequiredArgsConstructor
@CrossOrigin
public class FactoryOrderController {

    private final DataSourceService dataSourceService;
    private final FactoryOrderService factoryOrderService;

    @PostMapping("/create")
    public ResponseEntity<String> createManifest(
            @RequestBody FactoryOrderRequestDTO request,
            @RequestParam(required = false) String DB) {

        dataSourceService.updateDataSource(DB);
        factoryOrderService.processIncomingOrder(request);

        return new ResponseEntity<>("Manifest Created Successfully", HttpStatus.CREATED);
    }

    @GetMapping("/getAll")
    public ResponseEntity<List<FactoryOrderManifest>> getAllOrders(
            @RequestParam(required = false) String DB) {

        dataSourceService.updateDataSource(DB);
        List<FactoryOrderManifest> orders = factoryOrderService.getAllOrders();
        return new ResponseEntity<>(orders, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<FactoryOrderManifest> getOrderById(
            @PathVariable Long id,
            @RequestParam(required = false) String DB) {

        dataSourceService.updateDataSource(DB);
        FactoryOrderManifest order = factoryOrderService.getOrderById(id);
        return order != null ?
                new ResponseEntity<>(order, HttpStatus.OK) :
                new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<FactoryOrderManifest> updateOrderStatus(
            @PathVariable Long id,
            @RequestBody FactoryOrderRequestDTO updateRequest,
            @RequestParam(required = false) String DB) {

        dataSourceService.updateDataSource(DB);
        FactoryOrderManifest updatedOrder = factoryOrderService.updateOrder(id, updateRequest);
        return updatedOrder != null ?
                new ResponseEntity<>(updatedOrder, HttpStatus.OK) :
                new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> deleteOrder(
            @PathVariable Long id,
            @RequestParam(required = false) String DB) {

        dataSourceService.updateDataSource(DB);
        boolean deleted = factoryOrderService.deleteOrder(id);
        return deleted ?
                new ResponseEntity<>(HttpStatus.NO_CONTENT) :
                new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}