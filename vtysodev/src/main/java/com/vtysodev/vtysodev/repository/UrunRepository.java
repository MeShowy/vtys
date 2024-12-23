package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Urun;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UrunRepository extends JpaRepository<Urun, Integer> {

    @Query(value = """
    SELECT "urun_kodu", "urun_adi", "stok", "kategori_id", "birim_fiyat"
    FROM public.urun
    """, nativeQuery = true)
    List<Urun> getUrunList();

    @Query(value = """
    SELECT "urun_kodu", "urun_adi", "stok", "kategori_id", "birim_fiyat"
    FROM public.urun
    WHERE "urun_kodu" = :urunKodu
    """, nativeQuery = true)
    Optional<Urun> getUrun(@Param("urunKodu") int urunKodu);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.urun("urun_kodu", "urun_adi", "stok", "kategori_id", "birim_fiyat") 
    VALUES (default, :urunAdi, :stok, :kategoriId, :birimFiyat)
    """, nativeQuery = true)
    void saveUrun(Integer urunKodu, String urunAdi, Integer stok, Integer kategoriId, Integer birimFiyat);

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.urun 
    SET "urun_adi" = :urunAdi, "stok" = :stok, "kategori_id" = :kategoriId, "birim_fiyat" = :birimFiyat
    WHERE "urun_kodu" = :urunKodu
    """, nativeQuery = true)
    void updateUrun(Integer urunKodu, String urunAdi, Integer stok, Integer kategoriId, Integer birimFiyat);
}
