package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Ilce;
import com.vtysodev.vtysodev.model.Kategori;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface KategoriRepository extends JpaRepository<Kategori, Integer> {
    @Query(value = """
        SELECT * FROM public.kategori
    """, nativeQuery = true)
    List<Kategori> getKategori();
}
