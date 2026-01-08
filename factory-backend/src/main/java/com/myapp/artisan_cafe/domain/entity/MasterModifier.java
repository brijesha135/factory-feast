package com.myapp.artisan_cafe.domain.entity;
import jakarta.persistence.*;
import lombok.Data;
@Entity
@Table(name = "master_modifiers")
@Data
public class MasterModifier {
    @Id
    private String modifierCode;
    private String modifierName;
    private Double price;
}