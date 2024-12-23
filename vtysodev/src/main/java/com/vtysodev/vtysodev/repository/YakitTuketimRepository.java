package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.YakitTuketim;
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
public interface YakitTuketimRepository extends JpaRepository<YakitTuketim, Integer> {

    @Query(value = """
    SELECT "kayit_id", "arac_id", "tarih", "gidilen_mesafe", 
           "tuketilen_yakit", "yakit_maliyet", "yakit_fiyati"
    FROM public.yakit_tuketim
    """, nativeQuery = true)
    List<YakitTuketim> getYakitTuketimList();

    @Query(value = """
    SELECT "kayit_id", "arac_id", "tarih", "gidilen_mesafe", 
           "tuketilen_yakit", "yakit_maliyet", "yakit_fiyati"
    FROM public.yakit_tuketim
    WHERE "kayit_id" = :kayitId
    """, nativeQuery = true)
    Optional<YakitTuketim> getYakitTuketim(@Param("kayitId") int kayitId);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.yakit_tuketim(
        "kayit_id", "arac_id", "tarih", "gidilen_mesafe", 
        "tuketilen_yakit", "yakit_fiyati")
    VALUES (default, :aracId, :tarih, :gidilenMesafe, 
            :tuketilenYakit, :yakitFiyati)
    """, nativeQuery = true)
    void saveYakitTuketim(
            Integer kayitId, Integer aracId, Timestamp tarih,
            Integer gidilenMesafe, Integer tuketilenYakit, Integer yakitFiyati
    );

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.yakit_tuketim
    SET "arac_id" = :aracId, "tarih" = :tarih, "gidilen_mesafe" = :gidilenMesafe, 
        "tuketilen_yakit" = :tuketilenYakit, 
        "yakit_fiyati" = :yakitFiyati
    WHERE "kayit_id" = :kayitId
    """, nativeQuery = true)
    void updateYakitTuketim(
            Integer kayitId, Integer aracId, Timestamp tarih,
            Integer gidilenMesafe, Integer tuketilenYakit,
            Integer yakitFiyati
    );
}
