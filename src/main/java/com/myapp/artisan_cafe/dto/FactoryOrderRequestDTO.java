package com.myapp.artisan_cafe.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
public class FactoryOrderRequestDTO {
    @JsonProperty("manifestNo")
    private String manifestNo;

    @JsonProperty("licenseKey")
    private String licenseKey;

    @JsonProperty("outletBrand")
    private String brandName;

    // FIX 1: Use lowercase 'w' so Lombok generates getWorkflowStatus()
    @JsonProperty("workflowStatus")
    private String workflowStatus;

    @JsonProperty("fulfillmentType")
    private String fulfillmentType;

    // FIX 2: Removed the duplicate "workflowStatus" mapping here to avoid conflicts
    private String orderType;

    @JsonProperty("items")
    private List<LineItemDTO> items;

    @Data
    public static class LineItemDTO {
        @JsonProperty("productSku")
        private String productSku;

        @JsonProperty("itemDescription")
        private String itemName;

        @JsonProperty("receiveQty")
        private Integer quantity;

        @JsonProperty("unitBasePrice")
        private Double unitPrice;

        @JsonProperty("grossLineTotal")
        private Double totalPrice;

        private String taxJson;
        private List<AddonDTO> modifiers;
    }

    @Data
    public static class AddonDTO {
        private String modifierCode;
        private String modifierLabel;
        private Double price;
    }
}