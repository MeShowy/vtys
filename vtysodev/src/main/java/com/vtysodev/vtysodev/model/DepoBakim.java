package com.vtysodev.vtysodev.model;



import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Table(name = "depobakım",schema = "public")
@Data
@Entity
@IdClass(DepoBakim.class)
public class DepoBakim {
    @Id
    @Column(name = "depo_id")
    public Integer depoId;

    @Id
    @Column(name = "bakim_maliyet")
    public Integer bakimMaliyet;

    @Id
    @Column(name = "bakim_tur")
    public String bakimTur;

    @Id
    @Column(name = "bakim_tarih")
    public Timestamp bakimTarih;

}
