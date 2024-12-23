package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Depo;
import com.vtysodev.vtysodev.model.Fatura;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

public interface FaturaRepository extends JpaRepository<Fatura, Integer> {

    @Query(value = """
        SELECT * FROM public.fatura
    """, nativeQuery = true)
    List<Fatura> getFaturaList();

    @Query(value = """
        SELECT * FROM public.fatura order by "fatura_no" desc fetch first 1 rows only
    """, nativeQuery = true)
    Fatura getLastFatura();

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.fatura("fatura_no", "fatura_tarihi") 
    VALUES (default, :faturaTarihi)
    """, nativeQuery = true)
    void saveFatura(LocalDateTime faturaTarihi);

}
