package com.myapp.artisan_cafe.repository;

import com.myapp.artisan_cafe.domain.entity.FactoryOrderManifest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface FactoryOrderRepository extends JpaRepository<FactoryOrderManifest, Long> {

    Optional<FactoryOrderManifest> findByManifestNo(String manifestNo);

    List<FactoryOrderManifest> findByFulfillmentTypeIgnoreCase(String type);

    List<FactoryOrderManifest> findByOutletBrand(String brand);

    @Query("SELECT SUM(e.grossLineTotal) FROM ProductionLineItem e " +
            "WHERE e.manifest.manifestDate = :currentDate")
    Double calculateDailyRevenue(@Param("currentDate") String currentDate);
}