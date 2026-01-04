package com.myapp.artisan_cafe.repository;

import com.myapp.artisan_cafe.domain.entity.TaxRule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TaxRuleRepository extends JpaRepository<TaxRule, String> {
    List<TaxRule> findByIndicatorGroup(String indicatorGroup);
}