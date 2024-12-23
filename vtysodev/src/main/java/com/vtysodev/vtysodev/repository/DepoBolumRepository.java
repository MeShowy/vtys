package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.DepoBolum;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DepoBolumRepository extends JpaRepository<DepoBolum, Integer> {

    @Query(value = """
    SELECT "bolum_id", "depo_id", "kategori_id", "kapasite", "bolum_adi" 
    FROM public.depobolum
    """, nativeQuery = true)
    List<DepoBolum> getDepoBolumList();

    @Query(value = """
    SELECT "bolum_id", "depo_id", "kategori_id", "kapasite", "bolum_adi" 
    FROM public.depobolum
    WHERE "bolum_id" = :bolumId
    """, nativeQuery = true)
    Optional<DepoBolum> getDepoBolum(@Param("bolumId") int bolumId);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.depobolum("depo_id", "kategori_id", "kapasite", "bolum_adi") 
    VALUES (:depoId, :kategoriId, :kapasite, :bolumAdi)
    """, nativeQuery = true)
    void saveDepoBolum(Integer depoId, Integer kategoriId, Integer kapasite, String bolumAdi);

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.depobolum 
    SET "depo_id" = :depoId, "kategori_id" = :kategoriId, "kapasite" = :kapasite, "bolum_adi" = :bolumAdi
    WHERE "bolum_id" = :bolumId
    """, nativeQuery = true)
    void updateDepoBolum(Integer bolumId, Integer depoId, Integer kategoriId, Integer kapasite, String bolumAdi);
}
