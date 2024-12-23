package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.DepoBakim;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;

@Repository
public interface DepoBakimRepository extends JpaRepository<DepoBakim, Integer> {

    @Query(value = """
    SELECT "depo_id", "bakim_maliyet", "bakim_tur", "bakim_tarih" 
    FROM public.depobakım
    """, nativeQuery = true)
    List<DepoBakim> getDepoBakimList();

    @Query(value = """
    SELECT "depo_id", "bakim_maliyet", "bakim_tur", "bakim_tarih" 
    FROM public.depobakım
    WHERE "depo_id" = :depoId
    """, nativeQuery = true)
    Optional<DepoBakim> getDepoBakim(@Param("depoId") int depoId);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.depobakım("depo_id", "bakim_maliyet", "bakim_tur", "bakim_tarih") 
    VALUES (:depoId, :bakimMaliyet, :bakimTur, :bakimTarih)
    """, nativeQuery = true)
    void saveDepoBakim(Integer depoId, Integer bakimMaliyet, String bakimTur, Timestamp bakimTarih);

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.depobakım 
    SET "bakim_maliyet" = :bakimMaliyet, "bakim_tur" = :bakimTur, "bakim_tarih" = :bakimTarih 
    WHERE "depo_id" = :depoId
    """, nativeQuery = true)
    void updateDepoBakim(Integer depoId, Integer bakimMaliyet, String bakimTur, Timestamp bakimTarih);
}
