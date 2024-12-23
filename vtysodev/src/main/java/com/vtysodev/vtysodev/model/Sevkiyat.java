package com.vtysodev.vtysodev.model;


import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;
import lombok.*;

import java.sql.Timestamp;

@Table(name = "siparis",schema = "public")
@Data
@Entity
@IdClass(Sevkiyat.class)
public class Sevkiyat {
    @Id
    public Integer siparisNo;

    public Integer depoId;

    public Integer aracId;


    public Timestamp tarih;
}
