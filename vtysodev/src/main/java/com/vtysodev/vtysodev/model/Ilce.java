package com.vtysodev.vtysodev.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Table(name = "ilce",schema = "public")
@Data
@Entity
public class Ilce {
    @Column(name = "ilce_adi")
    public String ilceAdi;

    @Id
    @Column(name = "ilce_no")
    public Integer ilceNo;

    @Column(name = "il_no")
    public Integer ilNo;
}
