package com.myapp.artisan_cafe.repository;

import com.myapp.artisan_cafe.domain.entity.MasterVariant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MasterVariantRepository extends JpaRepository<MasterVariant, Integer> {

    List<MasterVariant> findBySkuCode(Integer skuCode);
}