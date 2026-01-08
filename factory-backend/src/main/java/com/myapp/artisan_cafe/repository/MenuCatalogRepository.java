package com.myapp.artisan_cafe.repository;

import com.myapp.artisan_cafe.domain.entity.MenuCatalog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MenuCatalogRepository extends JpaRepository<MenuCatalog, Integer> {
}