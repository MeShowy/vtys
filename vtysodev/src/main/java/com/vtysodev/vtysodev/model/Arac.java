package com.vtysodev.vtysodev.model;

import jakarta.persistence.*;
import lombok.*;


@Table(name = "Arac",schema = "public")
@Entity
@Data

public class Arac {
    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    @Column(name = "arac_id")
    public Integer aracId;

    @Column(name = "arac_tipi")
    public String aracTipi;
}
