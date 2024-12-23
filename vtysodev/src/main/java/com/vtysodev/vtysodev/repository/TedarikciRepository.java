package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Kategori;
import com.vtysodev.vtysodev.model.Tedarikci;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface TedarikciRepository extends JpaRepository<Tedarikci,Integer> {
    @Query(value = """
        SELECT * FROM public.tedarikci
    """, nativeQuery = true)
    List<Tedarikci> getTedarikci();
}
