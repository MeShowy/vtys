package com.vtysodev.vtysodev.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "urun",schema = "public")
@Data
@Entity
public class Urun {

    @Column(name = "urun_adi")
    public String urunAdi;

    @Column(name = "stok")
    public Integer stok;

    @Column(name = "kategori_id")
    public Integer kategoriId;

    @Column(name = "birim_fiyat")
    public Integer birimFiyat;

    @Id
    @Column(name = "urun_kodu")
    public Integer urunKodu;
}
