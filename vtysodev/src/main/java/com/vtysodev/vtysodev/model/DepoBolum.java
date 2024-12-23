package com.vtysodev.vtysodev.model;


import jakarta.persistence.*;
import lombok.*;

@Table(name = "depobolum",schema = "public")
@Data
@Entity
public class DepoBolum {

    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    @Column(name = "bolum_id")
    public Integer bolumId;

    @Column(name = "depo_id")
    public Integer depoId;

    @Column(name = "kategori_id")
    public Integer kategoriId;

    @Column(name = "kapasite")
    public Integer kapasite;

    @Column(name = "bolum_adi")
    public String bolumAdi;

}
