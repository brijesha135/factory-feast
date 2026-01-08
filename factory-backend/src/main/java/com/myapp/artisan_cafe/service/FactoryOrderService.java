package com.myapp.artisan_cafe.service;


import com.myapp.artisan_cafe.domain.entity.FactoryOrderManifest;
import com.myapp.artisan_cafe.domain.entity.ProductSpecificationAddon;
import com.myapp.artisan_cafe.domain.entity.ProductionLineItem;
import com.myapp.artisan_cafe.dto.FactoryOrderRequestDTO;
import com.myapp.artisan_cafe.repository.FactoryOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FactoryOrderService {

    private final FactoryOrderRepository repository;

    @Transactional
    public void processIncomingOrder(FactoryOrderRequestDTO dto) {
        FactoryOrderManifest manifest = new FactoryOrderManifest();
        manifest.setManifestNo(dto.getManifestNo());
        manifest.setLicenseKey(dto.getLicenseKey());
        manifest.setOutletBrand(dto.getBrandName());
        manifest.setFulfillmentType(dto.getFulfillmentType());
        manifest.setWorkflowStatus("PLACED");

        manifest.setItems(dto.getItems().stream().map(itemDto -> {
            ProductionLineItem item = new ProductionLineItem();
            item.setManifest(manifest);
            item.setProductSku(itemDto.getProductSku());
            item.setItemDescription(itemDto.getItemName());
            item.setReceiveQty(itemDto.getQuantity());
            item.setGrossLineTotal(itemDto.getTotalPrice());

            if(itemDto.getModifiers() != null) {
                item.setAddons(itemDto.getModifiers().stream().map(modDto -> {
                    ProductSpecificationAddon addon = new ProductSpecificationAddon();
                    addon.setLineItem(item);
                    addon.setModifierCode(modDto.getModifierCode());
                    addon.setModifierLabel(modDto.getModifierLabel());
                    addon.setUpchargePrice(modDto.getPrice());
                    return addon;
                }).collect(Collectors.toList()));
            }
            return item;
        }).collect(Collectors.toList()));

        repository.save(manifest);
    }


    public List<FactoryOrderManifest> getAllOrders() {
        return repository.findAll();
    }

    public FactoryOrderManifest getOrderById(Long id) {
        return repository.findById(id).orElse(null);
    }

    @Transactional
    public FactoryOrderManifest updateOrder(Long id, FactoryOrderRequestDTO dto) {
        return repository.findById(id).map(order -> {
            if(dto.getOrderType() != null) order.setFulfillmentType(dto.getOrderType());
            return repository.save(order);
        }).orElse(null);
    }

    @Transactional
    public boolean deleteOrder(Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return true;
        }
        return false;
    }
}