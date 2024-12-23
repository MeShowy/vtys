package com.vtysodev.vtysodev.model;


import jakarta.persistence.*;
import lombok.*;

@Table(name = "depo",schema = "public")
@Entity
@Data
public class Depo {
    @Id
    @GeneratedValue(strategy= GenerationType.IDENTITY)
    @Column(name = "depo_id")
    public Integer depoId;

    @Column(name = "ilce_no")
    public Integer ilceNo;

    @Column(name = "depo_adi")
    public String depoAdi;

    @Column(name = "kapasite")
    public Integer kapasite;
}
