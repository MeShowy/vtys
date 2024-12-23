package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Calisan;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CalisanRepository extends JpaRepository<Calisan, Integer> {

    @Query(value = """
    SELECT "calisan_id", "bolum_id", "ad", "soyad", "gorev_turu", 
           "maas", "departman", "deneyim", "arac_id", "arac_tipi"
    FROM calisan.calisan
    """, nativeQuery = true)
    List<Calisan> getCalisanList();

    @Query(value = """
    SELECT "calisan_id", "bolum_id", "ad", "soyad", "gorev_turu", 
           "maas", "departman", "deneyim", "arac_id", "arac_tipi"
    FROM calisan.calisan
    WHERE "calisan_id" = :calisanId
    """, nativeQuery = true)
    Optional<Calisan> getCalisan(@Param("calisanId") int calisanId);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO calisan.calisan(
        "calisan_id", "bolum_id", "ad", "soyad", "gorev_turu", 
        "maas", "departman", "deneyim", "arac_id", "arac_tipi")
    VALUES (default, :bolumId, :ad, :soyad, :gorevTuru, 
            :maas, :departman, :deneyim, :aracId, :aracTipi)
    """, nativeQuery = true)
    void saveCalisan(
            Integer calisanId, Integer bolumId, String ad, String soyad, String gorevTuru,
            Integer maas, String departman, Integer deneyim, Integer aracId, String aracTipi
    );

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE calisan.calisan
    SET "bolum_id" = :bolumId, "ad" = :ad, "soyad" = :soyad, "gorev_turu" = :gorevTuru,
        "maas" = :maas, "departman" = :departman, "deneyim" = :deneyim, 
        "arac_id" = :aracId, "arac_tipi" = :aracTipi
    WHERE "calisan_id" = :calisanId
    """, nativeQuery = true)
    void updateCalisan(
            Integer calisanId, Integer bolumId, String ad, String soyad, String gorevTuru,
            Integer maas, String departman, Integer deneyim, Integer aracId, String aracTipi
    );
}
