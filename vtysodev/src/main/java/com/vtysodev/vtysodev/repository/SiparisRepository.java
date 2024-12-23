package com.vtysodev.vtysodev.repository;

import com.vtysodev.vtysodev.model.Siparis;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.sql.Date;
import java.util.List;
import java.util.Optional;

@Repository
public interface SiparisRepository extends JpaRepository<Siparis, Integer> {


    @Query(value = """

            SELECT public.stoktan_urun_cikar(
          	:urunKodu,
            :miktar
              )
    """)
    String urunCikar(Integer urunKodu, Integer miktar);

    @Query(value = """
    SELECT public.stok_durumu_kontrol(
	:urunKodu
    )""")
    String stokDurumKontrol(Integer urunKodu);
    @Query(value = """
    SELECT public.siparisler_sira(
    	:siparisVeren
    	
    )
""")
     List<?> siparisVerilen(Integer siparisVeren);

    @Query(value = """
    SELECT public.siparis_durum_ogren(
    	:siparisNo,
    	:tarih
    )
""")
    String siparisDurumOgren(Integer siparisNo, Date tarih);

    @Query(value = """

            DELETE FROM public.siparisurun
    	WHERE "siparis_no" = :siparisNo""",nativeQuery = true)
    @Transactional
    @Modifying
    void deleteSiparisurun(@Param("siparisNo") Integer siparisNo);

    @Query(value = """
    SELECT "siparis_no", "urun_kodu", "siparis_adi", "birim_fiyat", 
           "fatura_no", "siparis_adet", "tutar", "siparis_veren"
    FROM public.siparisurun
    """, nativeQuery = true)
    List<Siparis> getSiparisList();

    @Query(value = """
    SELECT "siparis_no", "urun_kodu", "siparis_adi", "birim_fiyat", 
           "fatura_no", "siparis_adet", "tutar", "siparis_veren"
    FROM public.siparisurun
    WHERE "siparis_no" = :siparisNo
    """, nativeQuery = true)
    Optional<Siparis> getSiparis(@Param("siparisNo") int siparisNo);

    @Modifying
    @Transactional
    @Query(value = """
    INSERT INTO public.siparisurun(
        "siparis_no", "urun_kodu", "siparis_adi", "birim_fiyat", 
        "fatura_no", "siparis_adet", "tutar", "siparis_veren")
    VALUES (default, :urunKodu, :siparisAdi, :birimFiyat, 
            :faturaNo, :siparisAdet, default, :siparisVeren)
    """, nativeQuery = true)
    void saveSiparis(
            Integer siparisNo, Integer urunKodu, String siparisAdi, Integer birimFiyat,
            Integer faturaNo, Integer siparisAdet, Integer tutar, Integer siparisVeren
    );

    @Modifying
    @Transactional
    @Query(value = """
    UPDATE public.siparisurun
    SET "urun_kodu" = :urunKodu, "siparis_adi" = :siparisAdi, "birim_fiyat" = :birimFiyat,
        "fatura_no" = :faturaNo, "siparis_adet" = :siparisAdet,
        "siparis_veren" = :siparisVeren
    WHERE "siparis_no" = :siparisNo
    """, nativeQuery = true)
    void updateSiparis(
            Integer siparisNo, Integer urunKodu, String siparisAdi, Integer birimFiyat,
            Integer faturaNo, Integer siparisAdet, Integer tutar, Integer siparisVeren
    );
}
