package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Sevkiyat;
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
public interface SevkiyatRepository extends JpaRepository<Sevkiyat, Integer> {

    @Query(value = """
    SELECT "siparis_no", "depo_id", "arac_id", "tarih"
    FROM public.sevkiyat
    """, nativeQuery = true)
    List<Sevkiyat> getSevkiyatList();

    @Query(value = """
    SELECT "siparis_no", "depo_id", "arac_id", "tarih"
    FROM public.sevkiyat
    WHERE "siparis_no" = :siparisNo AND "depo_id" = :depoId AND "arac_id" = :aracId AND "tarih" = :tarih
    """, nativeQuery = true)
    Optional<Sevkiyat> getSevkiyat(
            @Param("siparisNo") Integer siparisNo,
            @Param("depoId") Integer depoId,
            @Param("aracId") Integer aracId,
            @Param("tarih") Timestamp tarih
    );

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.sevkiyat("siparis_no", "depo_id", "arac_id", "tarih")
    VALUES (:siparisNo, :depoId, :aracId, :tarih)
    """, nativeQuery = true)
    void saveSevkiyat(
            @Param("siparisNo") Integer siparisNo,
            @Param("depoId") Integer depoId,
            @Param("aracId") Integer aracId,
            @Param("tarih") Timestamp tarih
    );

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.sevkiyat
    SET "depo_id" = :depoId, "arac_id" = :aracId, "tarih" = :tarih
    WHERE "siparis_no" = :siparisNo 
    """, nativeQuery = true)
    void updateSevkiyat(
            @Param("siparisNo") Integer siparisNo,
            @Param("depoId") Integer depoId,
            @Param("aracId") Integer aracId,
            @Param("tarih") Timestamp tarih
    );
}
